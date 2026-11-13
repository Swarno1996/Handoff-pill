#!/usr/bin/env bash
# capture_env.sh: snapshot the working environment as a pill manifest draft.
#
# Prints YAML to stdout. Read-only: it changes nothing on the machine.
# Never prints secret values: MCP env vars and headers are listed by NAME only,
# and credentials embedded in URLs are redacted.
#
# Usage: bash capture_env.sh [repo_dir ...]
#   With no arguments it scans the current directory and its direct children
#   for git repositories.

set -u
export LC_ALL=C

have() { command -v "$1" >/dev/null 2>&1; }
home_rel() { local p="$1"; printf '%s' "${p/#$HOME/\~}"; }
redact() { sed -E 's#(https?://)[^/@[:space:]]+@#\1<REDACTED>@#g; s#((token|key|secret|password)=)[^&[:space:]]+#\1<REDACTED>#Ig'; }
q() { local s="$1"; s=${s//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

echo "pill: 2"
echo "generated: $(date +%Y-%m-%dT%H:%M%z)"
echo "source:"
if [ -n "${CLAUDECODE:-}" ] || have claude; then
  echo "  platform: claude-code"
else
  echo "  platform: other"
fi
echo "  chat: \"<fill in>\""

# runtime -------------------------------------------------------------------
echo "runtime:"
os="$(uname -s) $(uname -r)"
# shellcheck disable=SC1091
if [ -r /etc/os-release ]; then os="$(. /etc/os-release; echo "${PRETTY_NAME:-$os}")"
elif have sw_vers; then os="macOS $(sw_vers -productVersion)"; fi
echo "  os: $(q "$os")"
echo "  workdir: $(q "$(home_rel "$PWD")")"
echo "  languages:"
ver() { # ver <label> <command...>: print a version line only if the probe succeeds
  local label="$1"; shift
  have "$1" || return 0
  local v; v="$("$@" 2>/dev/null | head -1)" || return 0
  [ -n "$v" ] && echo "    $label: $(q "$v")"
  return 0
}
ver python      python3 -c 'import platform;print(platform.python_version())'
ver node        sh -c 'node --version | sed "s/^v//"'
# shellcheck disable=SC2016  # $N is for awk inside sh -c, not for this shell
ver go          sh -c 'go version | awk "{print \$3}" | sed "s/^go//"'
# shellcheck disable=SC2016
ver rust        sh -c 'rustc --version | awk "{print \$2}"'
# shellcheck disable=SC2016
ver java        sh -c 'java -version 2>&1 | head -1 | awk -F"\"" "{print \$2}"'
ver claude_code claude --version

# repos ---------------------------------------------------------------------
repos=()
if [ "$#" -gt 0 ]; then
  repos=("$@")
else
  git -C . rev-parse --show-toplevel >/dev/null 2>&1 && repos+=("$(git -C . rev-parse --show-toplevel)")
  for d in ./*/; do
    [ -d "$d/.git" ] && repos+=("$(cd "$d" && pwd)")
  done
fi
if [ "${#repos[@]}" -gt 0 ]; then
  echo "repos:"
  for r in "${repos[@]}"; do
    git -C "$r" rev-parse >/dev/null 2>&1 || continue
    url="$(git -C "$r" remote get-url origin 2>/dev/null | redact)"
    branch="$(git -C "$r" branch --show-current 2>/dev/null)"
    commit="$(git -C "$r" rev-parse --short HEAD 2>/dev/null)"
    dirty=false; [ -n "$(git -C "$r" status --porcelain 2>/dev/null)" ] && dirty=true
    unpushed="$(git -C "$r" rev-list --count '@{u}..HEAD' 2>/dev/null || echo unknown)"
    echo "  - path: $(q "$(home_rel "$r")")"
    [ -n "$url" ] && echo "    url: $(q "$url")"
    echo "    branch: $(q "${branch:-detached}")"
    echo "    commit: $(q "$commit")"
    echo "    dirty: $dirty"
    echo "    unpushed: $unpushed"
    if [ -n "$url" ]; then
      name="$(basename "$url" .git)"
      echo "    restore: $(q "git clone $url && git -C $name checkout ${branch:-$commit}")"
    fi
  done
fi

# dependency manifests --------------------------------------------------------
found=()
for r in "${repos[@]:-.}"; do
  for f in requirements.txt requirements-dev.txt pyproject.toml Pipfile package.json Cargo.toml go.mod Gemfile environment.yml Dockerfile docker-compose.yml; do
    [ -f "$r/$f" ] && found+=("$(home_rel "$r")/$f")
  done
done
if [ "${#found[@]}" -gt 0 ]; then
  echo "dependency_files:   # restore with the matching package manager"
  for f in "${found[@]}"; do echo "  - $(q "$f")"; done
fi

# MCP servers -----------------------------------------------------------------
# Read config files directly so nothing is executed; names, transport and
# scope only. Env and header VALUES are never printed.
mcp_files=()
[ -f "$HOME/.claude.json" ] && mcp_files+=("user:$HOME/.claude.json")
for r in "${repos[@]:-.}"; do
  [ -f "$r/.mcp.json" ] && mcp_files+=("project:$r/.mcp.json")
done
if [ "${#mcp_files[@]}" -gt 0 ] && have python3; then
  python3 -I - "${mcp_files[@]}" <<'PY'
import json, sys, re
out = []
for spec in sys.argv[1:]:
    scope, path = spec.split(":", 1)
    try:
        data = json.load(open(path))
    except Exception:
        continue
    servers = dict(data.get("mcpServers", {}) or {})
    if scope == "user":
        # ~/.claude.json also holds per-project servers; include the one for cwd
        import os
        proj = (data.get("projects", {}) or {}).get(os.getcwd(), {}) or {}
        for k, v in (proj.get("mcpServers", {}) or {}).items():
            servers.setdefault(k, dict(v, _scope="local"))
    for name, cfg in servers.items():
        if not isinstance(cfg, dict):
            continue
        s = cfg.get("_scope", scope)
        transport = cfg.get("type") or ("stdio" if "command" in cfg else "http")
        secrets = sorted(set(list((cfg.get("env") or {}).keys()) + list((cfg.get("headers") or {}).keys())))
        if transport == "stdio":
            cmd = " ".join([cfg.get("command", "")] + [str(a) for a in cfg.get("args", [])]).strip()
            restore = f"claude mcp add --scope {'user' if s=='user' else 'project'} {name} -- {cmd}"
        else:
            url = re.sub(r"(https?://)[^/@\s]+@", r"\1<REDACTED>@", cfg.get("url", ""))
            url = re.sub(r"((?:token|key|secret|password)=)[^&\s]+", r"\1<REDACTED>", url, flags=re.I)
            restore = f"claude mcp add --scope {'user' if s=='user' else 'project'} --transport {transport} {name} {url}"
        out.append((name, s, transport, secrets, restore))
if out:
    print("mcp_servers:")
    for name, s, t, secrets, restore in out:
        print(f"  - name: {json.dumps(name)}")
        print(f"    scope: {s}")
        print(f"    transport: {t}")
        if secrets:
            print(f"    secrets: {json.dumps(secrets)}   # names only; values must be set by the user")
        print(f"    restore: {json.dumps(restore)}")
PY
fi

# skills and plugins ----------------------------------------------------------
list_skills() {
  local dir="$1" scope="$2"
  [ -d "$dir" ] || return 0
  for s in "$dir"/*/; do
    [ -f "$s/SKILL.md" ] || continue
    echo "  - name: $(q "$(basename "$s")")"
    echo "    scope: $scope"
    echo "    path: $(q "$(home_rel "${s%/}")")"
  done
}
skills_out="$(list_skills "$HOME/.claude/skills" user; for r in "${repos[@]:-.}"; do list_skills "$r/.claude/skills" project; done)"
if [ -n "$skills_out" ]; then
  echo "skills:   # add a restore line for any that came from a repo or marketplace"
  printf '%s\n' "$skills_out"
fi

pfile="$HOME/.claude/plugins/installed_plugins.json"
if [ -f "$pfile" ] && have python3; then
  python3 -I - "$pfile" <<'PY'
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
plugins = data.get("plugins", data) if isinstance(data, dict) else {}
keys = [k for k in plugins.keys()] if isinstance(plugins, dict) else []
if keys:
    print("plugins:")
    for k in sorted(keys):
        name, _, market = k.partition("@")
        print(f"  - name: {json.dumps(name)}")
        if market:
            print(f"    marketplace: {json.dumps(market)}")
            print(f"    restore: {json.dumps(f'/plugin install {name}@{market}')}")
PY
fi

echo "# Review before pasting: trim entries the work did not use, add files_required,"
echo "# connectors, env_vars (names only) and not_portable from the conversation."
