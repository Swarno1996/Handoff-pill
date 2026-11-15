# Pill manifest spec (pill: 2)

The manifest is the environment half of the pill: what to rebuild before the
work can continue. It sits right after the pill's title in a fenced `yaml`
block. Keys are optional unless marked required; omit empty sections rather
than writing `[]`.

```yaml
pill: 2                                   # required, schema version
project: infi-os                          # required, short slug
generated: 2026-11-13T13:20+01:00         # required, ISO 8601
source:                                   # required
  platform: claude-code                   # claude-code | claude-ai | chatgpt | gemini | cursor | codex | other
  chat: "Infi OS milestone 7 build"       # title or short description
  model: claude-opus-5-5                  # if known
  permission_mode: default                # Claude Code only, if relevant

runtime:                                  # where the work ran
  os: "Ubuntu 24.04"
  workdir: ~/projects/infi-os             # use ~, not the user's full home path
  languages: { python: "3.12.3", node: "22.4.0" }

repos:                                    # every repo the work touches
  - url: https://github.com/owner/repo
    path: ~/projects/infi-os
    branch: feature/scheduler
    commit: 3f2a9c1                       # HEAD at generation time
    dirty: true                           # uncommitted changes exist
    unpushed: 2                           # local commits not on remote
    restore: "git clone https://github.com/owner/repo && git -C repo checkout feature/scheduler"
    note: "Uncommitted scheduler.c changes live only on the user's disk"

packages:                                 # installs the work depends on
  - manager: pip                          # pip | npm | apt | brew | cargo | other
    name: qemu-utils
    version: "8.2"
    restore: "sudo apt-get install -y qemu-utils"
    why: "Boot tests run the image in QEMU"

mcp_servers:                              # MCP servers used in the chat
  - name: github
    scope: user                           # user | project | local | connector
    transport: http                       # stdio | http | sse
    restore: "claude mcp add --transport http github https://api.example.com/mcp"
    secrets: [GITHUB_TOKEN]               # names only, never values
    used_for: "Opening PRs and reading CI logs"
    fallback: "gh CLI with the user's own login"

connectors:                               # chat-app connectors (Claude.ai and similar)
  - name: Google Drive
    used_for: "Reading the spec doc"
    restore: "User connects Google Drive in Settings > Connectors"
    fallback: "User uploads the spec as a file"

skills:
  - name: handoff-pill
    source: "github.com/Swarno1996/Handoff-pill"
    restore: "/plugin install handoff-pill@handoff-pill"

plugins:
  - name: some-plugin
    marketplace: owner/marketplace-repo
    restore: "/plugin marketplace add owner/marketplace-repo && /plugin install some-plugin@marketplace-name"

files_required:                           # files the next chat cannot work without
  - name: infi-os-m7.tar.gz
    needed_for: "build and test work"
    lives: "user's Downloads folder; delivered at end of source chat"
    restore: "User uploads it at the start of the new chat"

env_vars:                                 # names and where they are set, never values
  - name: ANTHROPIC_API_KEY
    where: "~/.zshrc on the user's machine"
    needed_for: "the eval script"

not_portable:                             # capabilities that cannot be rebuilt here
  - "Local stdio MCP server 'qemu-ctl' cannot run in Claude.ai; fall back to giving the user commands to run"
```

## Rules

- **Every restorable entry has `restore`.** It is either an exact command or
  an exact user action. If neither exists, move the entry to `not_portable`.
- **No secret values anywhere.** Redact tokens inside URLs and commands as
  `<REDACTED>` and list the variable name under `secrets` or `env_vars`.
- **No personal paths.** Write `~` instead of `/Users/<name>`.
- **Record what was used,** not everything installed. A manifest of 60
  unused packages hides the 3 that matter.
- **Commit hashes are the pin.** A repo entry without `commit` cannot be
  checked for drift.
- **Restore commands are suggestions, not instructions.** The ingesting
  agent shows them to the user before running any.

## Platform notes

| Platform | Persists across chats | Must be restored per chat |
|---|---|---|
| Claude Code | MCP servers (user/project scope), skills and plugins in `~/.claude`, the user's files and repos | Conversation context only, plus anything installed in a throwaway container |
| Claude.ai | Connectors and uploaded skills (account level), memory, project knowledge | Sandbox installs, uploaded files, cloned repos, generated files |
| ChatGPT, Gemini and other chat apps | Account features (memory, custom instructions, GPTs or Gems) | Uploaded files, code interpreter installs |
| Cursor, Codex, Gemini CLI and other repo agents | Rules files and MCP config in the repo or home folder | Conversation context |

So on Claude.ai a new chat usually already has the connectors and skills;
rehydration there is mostly re-uploading files and replaying sandbox
installs. In Claude Code the environment is usually already present on disk,
and rehydration is mostly a drift check plus restoring context.
