# Fleetwatch: Handoff Pill (through v0.4, alerting milestone)

**Purpose.** Upload or paste this file at the start of a new chat. The
manifest rebuilds the environment; the sections below restore the context.
The new chat starts with a fresh token budget and loads only this file.

> Fictional example, written to show the v2 shape. Every name, path and
> number is invented.

```yaml
pill: 2
project: fleetwatch
generated: 2026-11-13T13:30+01:00
source: { platform: claude-code, chat: "Fleetwatch alerting milestone", model: claude-opus-5-5 }

runtime:
  os: "Ubuntu 24.04"
  workdir: ~/code/fleetwatch
  languages: { python: "3.12.3", node: "22.4.0" }

repos:
  - url: https://github.com/example/fleetwatch
    path: ~/code/fleetwatch
    branch: feat/alerting
    commit: 9c41e7a
    dirty: true
    unpushed: 1
    restore: "git clone https://github.com/example/fleetwatch && git -C fleetwatch checkout feat/alerting"
    note: "rules.py edits are uncommitted and exist only on the user's disk"

packages:
  - { manager: pip, name: prometheus-client, version: "0.21.0", restore: "pip install prometheus-client==0.21.0", why: "metrics endpoint" }

mcp_servers:
  - name: github
    scope: user
    transport: http
    secrets: [GITHUB_TOKEN]
    restore: "claude mcp add --scope user --transport http github https://mcp.example.com/github"
    used_for: "PRs and CI logs"
    fallback: "gh CLI"
  - name: grafana
    scope: project
    transport: stdio
    secrets: [GRAFANA_API_KEY]
    restore: "claude mcp add --scope project grafana -- npx -y grafana-mcp"
    used_for: "Reading dashboard JSON to check alert thresholds"

skills:
  - { name: handoff-pill, source: "github.com/Swarno1996/Handoff-pill", restore: "/plugin install handoff-pill@handoff-pill" }

files_required:
  - { name: staging-incidents.csv, needed_for: "threshold tuning", lives: "~/Downloads", restore: "User attaches it or keeps it in the repo's data/ folder" }

env_vars:
  - { name: GRAFANA_API_KEY, where: "~/.zshrc", needed_for: "grafana MCP server" }

not_portable:
  - "grafana stdio MCP server cannot run in Claude.ai; there, ask the user to export dashboard JSON as a file"
```

**Critical operational facts.** Conversation context does not carry over;
everything else above lives on the user's machine and persists. Before any
push, commit the uncommitted `rules.py` changes. Threshold work needs
`staging-incidents.csv`; without it the next chat can write code but cannot
tune thresholds. The grafana server needs `GRAFANA_API_KEY` set in the shell
that launches Claude Code.

---

## 1. What Fleetwatch is

Internal service health monitor for 40 delivery vans' telematics. v0.4 adds
alerting. Decisions: alerts are rule files, not code (ops edits them without
deploys); one Slack channel per severity (agreed with ops lead, do not merge).

## 2. Current state

`rules.py` loads YAML rules from `rules/`; 6 rules written, 4 tested.
Metrics on `:9108/metrics`. Alert latency p95 measured at 41 s; target 30 s.

## 3. Artifact inventory

| Artifact | Lives | Notes |
|---|---|---|
| `rules/*.yaml` | repo, committed | 6 rules |
| `rules.py` | repo, uncommitted | debounce logic |
| `staging-incidents.csv` | user's Downloads | 3 weeks of incidents |

## 4. How to work

`make test` runs unit tests; `make replay CSV=staging-incidents.csv` replays
incidents against the rules and prints hit and miss counts.

## 5. Environment sharp edges

- Never run `make replay` without `--speed 50`, because real-time replay
  takes 3 weeks.
- The grafana MCP server times out on dashboards over 2 MB; request panels
  one at a time.

## 6. Casebook

- **Duplicate alerts every 60 s.** Root cause: debounce keyed on rule name,
  not rule plus van ID. Fix: composite key in `rules.py:dedupe_key`.
  Diagnostic: logging the key exposed identical keys across vans.

## 7. Standing directives

- All work: "Reproduce first, then fix. One targeted change at a time."
- This project: "Never page on-call for severity 3."

## 8. State of play

In flight: rule 5 (battery voltage) threshold tuning. Open question to the
user, unanswered: "Should a van offline for over 2 hours page, or only post
to Slack?"

## 9. Roadmap

1. Answer the offline question, then write rule 7.
2. Bring p95 alert latency under 30 s (suspect: 15 s scrape interval).
3. Open PR from `feat/alerting`.

## 10. How to resume

1. Run `/pill-load FLEETWATCH_HANDOFF_PILL.md` or upload this file.
2. Approve the rehydration plan; set `GRAFANA_API_KEY` if it reports missing.
3. Attach `staging-incidents.csv` for tuning work.
4. Re-ask the open question in section 8, then continue the roadmap.

---

*Generated 2026-11-13 by handoff-pill v2, at the end of the "Fleetwatch
alerting milestone" session on Claude Code. Sources: the live conversation,
capture_env.sh output.*
