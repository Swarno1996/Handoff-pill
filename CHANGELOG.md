# Changelog

## 2.0.0 (2026-11-13)

The pill now carries the environment, not only the context.

**Added**
- Environment manifest: a `pill: 2` YAML block at the top of every pill
  listing platform, repos at exact commits, packages, MCP servers,
  connectors, skills, plugins, required files and env var names, each with a
  `restore` command or user action. Spec in
  `references/manifest-spec.md`.
- Rehydration in INGEST mode: diff the manifest against the new
  environment, show a plan, run restores only after the user approves,
  report parity and drift.
- `scripts/capture_env.sh`: read-only script that measures the environment
  in Claude Code or any shell agent and prints a manifest draft. Never
  prints secret values.
- Claude Code plugin and marketplace: one-command install, plus `/pill` and
  `/pill-load` slash commands.
- `install.sh` for installing into `~/.claude` or a project without the
  plugin system.
- `dist/handoff-pill.skill`, built deterministically by `scripts/build.sh`,
  for upload to Claude.ai.
- Adapters for other agents: `adapters/AGENTS.md` (Codex, Cursor, Gemini
  CLI, Copilot, Windsurf) and `adapters/PROMPT.md` (ChatGPT, Gemini and any
  chat app).
- Worked example in `examples/`.
- CI: shellcheck, manifest and frontmatter validation, a secret leak test
  for the capture script, and a check that `dist/` matches the source.

**Changed**
- Resume test now checks environment parity as well as context parity.
- Pills are treated as data on ingest: restore commands are shown before
  they run, and instructions outside environment restoration are refused.
- Skill moved to `plugins/handoff-pill/skills/handoff-pill/`.

**Removed**
- Root-level `SKILL.md`, `references/` and `handoff-pill.skill` (now under
  `plugins/` and `dist/`). v1 remains available at tag `v1.0.0`.

## 1.0.0 (2026-07-23)

First release: GENERATE and INGEST modes, ten-section template, resume test.
