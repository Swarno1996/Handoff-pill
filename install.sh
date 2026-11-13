#!/usr/bin/env bash
# Install the Handoff Pill skill and slash commands into Claude Code without
# the plugin system. Prefer the plugin install in README.md when available.
#
#   ./install.sh            install for your user   (~/.claude)
#   ./install.sh --project  install for this project (./.claude)
#   ./install.sh --uninstall [--project]
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/plugins/handoff-pill"
target="$HOME/.claude"
mode=install
for arg in "$@"; do
  case "$arg" in
    --project) target="$PWD/.claude" ;;
    --uninstall) mode=uninstall ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

skill_dst="$target/skills/handoff-pill"
cmd_dst="$target/commands"

if [ "$mode" = uninstall ]; then
  rm -rf "$skill_dst"
  rm -f "$cmd_dst/pill.md" "$cmd_dst/pill-load.md"
  echo "Removed Handoff Pill from $target"
  exit 0
fi

mkdir -p "$target/skills" "$cmd_dst"
rm -rf "$skill_dst"
cp -R "$src/skills/handoff-pill" "$skill_dst"
chmod +x "$skill_dst/scripts/capture_env.sh"
# Outside the plugin system ${CLAUDE_PLUGIN_ROOT} is unset; the commands
# already fall back to the skills folder path.
cp "$src/commands/pill.md" "$src/commands/pill-load.md" "$cmd_dst/"

echo "Installed Handoff Pill v2 into $target"
echo "  skill:    $skill_dst"
echo "  commands: /pill  /pill-load"
echo "Restart Claude Code, then say \"make the pill\" or run /pill."
