# Pill template

The canonical section order. Keep every section's spirit; rename to fit the
domain. Inline guidance is in [brackets]; delete it in the real pill.

---

# <Project>: Handoff Pill (through <version or milestone>)

**Purpose.** Upload or paste this file at the start of a new chat. The
manifest rebuilds the environment; the sections below restore the context.
The new chat starts with a fresh token budget and loads only this file.

```yaml
pill: 2
project: <slug>
generated: <ISO 8601 date and time>
source: { platform: <claude-code | claude-ai | ...>, chat: "<title>", model: <id> }
# [Fill from references/manifest-spec.md. In Claude Code, paste the output of
#  scripts/capture_env.sh here and trim to what the work used. Every entry
#  that must be restored carries a `restore` field. No secret values.]
```

**Critical operational facts.** [The most load-bearing prose. State what
does not survive the chat boundary on this platform: sandbox installs,
in-chat files, uploads. Name exactly which files the user must bring for
which kinds of work, and which manifest items only the user can restore
(connectors, secrets, uploads). Example: "To do build work, upload
`<artifact.tar.gz>` and connect GitHub; without them a new chat can reason
and write code but cannot build, test or push."]

---

## 1. What <project> is

[One dense paragraph: what it is, what makes it distinct, current version or
state. Then the small set of load-bearing principles or decisions, each one
line, with enough of the why that they cannot be casually reversed.]

## 2. Current state / architecture

[The shape of the thing as it exists now. For software: components, layout,
key numbers (sizes, versions, ports, paths). For writing or research: the
document set, structure, thesis, sources. Exact values as of the end of this
chat; where they supersede an older document, say so.]

## 3. Artifact inventory

[Every artifact that exists, where it lives, what it does. Mark clearly
which exist only outside any chat (user's disk, a repo, a delivered
download) and which can be rebuilt from what. Tables are fine.]

## 4. How to work

[The procedures that are known to work, as exact commands or steps: build
chain, test invocation, review workflow, submission process. Copy-pasteable.]

## 5. Environment constraints and sharp edges

[Everything about the working environment learned by violating it: limits,
timeouts, quotas, tool quirks, ordering requirements, things that fail
silently. One line each, imperative: "Never X, because Y."]

## 6. Casebook: problems solved

[The highest-value section. Every non-obvious problem: symptom, root cause,
fix, one entry each. Include the diagnostic that located it when the method
generalizes. Never trimmed to look clean.]

## 7. Standing directives

[Every instruction or correction the user gave about how to work, at its
intended strength. Mark which apply to all future work versus only this
project. These are quoted intent, not paraphrase softened for politeness.]

## 8. State of play

[What was in flight at the moment of generation. Decisions pending, and who
owes the answer. Questions asked of the user and not yet answered, verbatim,
so the next chat re-asks instead of guessing.]

## 9. Roadmap

[Agreed next steps in priority order, with enough context that each is
actionable without re-discussion.]

## 10. How to resume in a new chat

[Numbered protocol: 1. Upload this pill. 2. Upload <named artifacts> if
<kind of work> is needed. 3. Let the agent show its rehydration plan
(present, missing, not portable) and approve it. 4. Do the user-side
restores it lists. 5. State the target task. 6. Expect <the normal working
loop>. Include any bookkeeping that must happen on changes, e.g. "a version
bump touches these four places."]

---

*Generated <date> by handoff-pill v2, at the end of the "<chat title>"
session on <platform>. Sources: [the live conversation, capture_env.sh
output, delivered artifacts, prior documents used].*
