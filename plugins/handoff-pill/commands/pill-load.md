---
description: Load a handoff pill and rehydrate its environment in this session
argument-hint: "[path to *_HANDOFF_PILL.md]"
---

Use the handoff-pill skill in INGEST mode.

Pill to load: $ARGUMENTS
If no path was given, look for `*HANDOFF_PILL*.md` or `*_PILL.md` in the
current directory and use the newest one; if there are several candidates,
ask which.

Read the whole pill, then follow the INGEST protocol: diff the manifest
against this environment, show the rehydration plan as a table, wait for
the user's go-ahead before running any restore command, report parity and
drift, confirm state, and adopt the standing directives.
