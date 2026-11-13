# Handoff Pill instructions for coding agents

Copy this section into your agent's instruction file: `AGENTS.md` (Codex,
and other agents that read it), `.cursor/rules/handoff-pill.mdc` (Cursor),
`GEMINI.md` (Gemini CLI), `.github/copilot-instructions.md` (Copilot), or
`.windsurfrules` (Windsurf). Also copy `scripts/capture_env.sh` from
`plugins/handoff-pill/skills/handoff-pill/scripts/` into the repo, for
example to `tools/capture_env.sh`.

---

## Handoff pill

When the user says "make the pill", "handoff pill", or that this session is
too long and should continue in a fresh one:

1. Run `bash tools/capture_env.sh` and keep its YAML output.
2. Write `<PROJECT>_HANDOFF_PILL.md` in the repo root containing, in order:
   - Title, then a fenced `yaml` manifest starting with `pill: 2`: source
     platform and model, runtime, repos with commit and dirty state, packages,
     MCP servers, required files, env var NAMES (never values), and anything
     not portable. Every entry that must be restored has a `restore` command
     or user action.
   - Critical operational facts: what does not carry over and what the user
     must bring.
   - What the project is; current state; artifact inventory; how to work
     (exact commands); environment sharp edges; casebook of solved problems
     (symptom, root cause, fix); the user's standing directives at full
     strength; state of play with open questions verbatim; roadmap; how to
     resume.
3. No secrets. Redact tokens. Use `~` instead of home paths.
4. Before saving, check: could a fresh agent with only this file and the
   listed restores do every roadmap step without asking the user to
   re-explain? If not, add what is missing.

When a session starts and the user points to a `*_HANDOFF_PILL.md`, or one
is in the repo root and the user asks to resume:

1. Read the whole file first.
2. Compare the manifest with this environment and show a table: item,
   present / missing / not portable, action.
3. Run no restore command until the user approves the plan.
4. Report drift (repo HEAD moved, files changed), confirm the project state
   and open questions in a few lines, and follow the standing directives as
   if the user had just typed them.
