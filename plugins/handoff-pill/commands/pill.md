---
description: Generate a handoff pill (context plus environment manifest) for this session
argument-hint: "[project-name] [output-path]"
---

Use the handoff-pill skill in GENERATE mode for this session.

1. Run the skill's capture script to measure the environment:
   `bash "${CLAUDE_PLUGIN_ROOT}/skills/handoff-pill/scripts/capture_env.sh"`
   If that path does not exist (skill installed without the plugin), use
   `bash ~/.claude/skills/handoff-pill/scripts/capture_env.sh`.
2. Trim the manifest to what this session actually used, and add
   files_required, connectors, env_vars (names only) and not_portable.
3. Write the full pill following the skill's template and pass its resume
   test before saving.
4. Save it as `<PROJECT>_HANDOFF_PILL.md` in the project root, or at the
   path given in the arguments.

Arguments, if any: $ARGUMENTS

Finish with two lines: what the pill carries, and what the user must bring
or reconnect in the next session.
