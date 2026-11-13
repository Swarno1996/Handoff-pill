#!/usr/bin/env bash
# Build dist/handoff-pill.skill: the upload file for Claude.ai
# (Settings > Capabilities > Skills > Upload). The zip is deterministic, so CI
# can check that the committed file matches the source.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -I - "$root" <<'PY'
import os, sys, zipfile
root = sys.argv[1]
src = os.path.join(root, "plugins", "handoff-pill", "skills", "handoff-pill")
out = os.path.join(root, "dist", "handoff-pill.skill")
os.makedirs(os.path.dirname(out), exist_ok=True)
files = []
for d, _, fs in os.walk(src):
    for f in fs:
        files.append(os.path.join(d, f))
with zipfile.ZipFile(out, "w", zipfile.ZIP_STORED) as z:
    for p in sorted(files):
        arc = os.path.join("handoff-pill", os.path.relpath(p, src))
        info = zipfile.ZipInfo(arc, date_time=(2026, 1, 1, 0, 0, 0))
        info.compress_type = zipfile.ZIP_STORED  # stored, so bytes match across zlib versions
        info.external_attr = (0o755 if p.endswith(".sh") else 0o644) << 16
        with open(p, "rb") as fh:
            z.writestr(info, fh.read())
print(f"built {os.path.relpath(out, root)} ({len(files)} files)")
PY
