---
name: handoff-pill
description: "Generate a handoff pill, a single dense markdown file that carries a long chat's full context, decisions, solved problems, and the user's working directives into a fresh chat. Use whenever the user says pill, handoff pill, context pill, or ingestible pill; asks to package, transfer, or hand off this conversation to a new chat; says the chat is getting too long or slow and wants to continue elsewhere without losing context; or asks to distill the session's learnings into a portable file. Also use in reverse, whenever a file named like *_PILL.md or *HANDOFF*.md is uploaded or pasted at the start of a chat, by following this skill's ingestion protocol before doing anything else."
---

# Handoff Pill

A pill is a context transfer artifact. The receiving chat starts with zero
memory of this one and a fresh container: every file built here is gone,
every lesson unlearned, every correction the user made forgotten. The pill's
one job is to make re-derivation unnecessary. It is written for the next
Claude, not for a human reader.

There are two modes. GENERATE when the user asks for a pill. INGEST when a
pill arrives at the start of a chat.

## What is expensive to lose (priority order for what goes in)

1. Root causes of solved problems. A bug that cost hours to diagnose costs
   hours again in the next chat if only the fix is recorded. Symptom, root
   cause, fix: all three, every time.
2. Environment sharp edges. Constraints of the working environment that were
   learned by violating them (timeouts, quotas, tool quirks, things that
   silently fail). These are invisible until they bite.
3. The user's standing directives. Every correction they made about how to
   work, at the strength they meant it. A preference stated once in chat 1
   and forgotten in chat 2 will be restated with less patience.
4. Exact current state. Version strings, sizes, paths, commands, numbers as
   of the end of this chat. The pill supersedes older documents; where it
   corrects one, say so.
5. Open threads. Decisions pending, questions asked but not yet answered by
   the user, work in flight at the moment of generation.

Cheap to lose, so leave out: prose explanation, anything re-derivable from
public documentation, the conversational back and forth, dead ends that
taught nothing.

## GENERATE mode

### Step 1: Inventory the chat

Walk the whole conversation and collect, into working notes:

- Project identity: what is being built or done, current version or state.
- Load-bearing decisions and the reasoning that earned them.
- Artifacts produced: files, documents, packages, where each lives NOW and
  which exist only outside the chat (delivered downloads, the user's disk,
  a repo).
- Working procedures: build chains, test commands, workflows, exact
  invocations that are known to work.
- Every non-obvious problem solved: symptom, root cause, fix.
- Environment constraints discovered the hard way.
- Every instruction or correction the user gave about how to work.
- What was in flight and what is undecided at this moment.
- The agreed next steps.

### Step 2: Write the pill

Read `references/pill-template.md` and follow its section order. Section
names may flex to fit the domain (a writing project has "drafts and
versions" where an OS project has "build chain") but every section's spirit
must be served or its absence justified.

### Rules that make a pill work

1. Write telegraphic and exact. Reference-manual density, not narrative.
   The reader is a model with the pill in context; it does not need to be
   persuaded, it needs to be loaded.
2. Operational facts come first, right after the header. State plainly what
   does not cross the chat boundary and exactly which files the user must
   re-upload for which kinds of work. Name the files. This is the single
   most load-bearing section: without it the next chat confidently attempts
   work it cannot do.
3. Never omit failures to look clean. The casebook of solved problems is
   the highest-value cargo in the pill.
4. Quote the user's directives at their intended strength ("never X",
   "always Y"), and mark which apply to all future work versus this project.
5. Record open questions verbatim, including ones the user has not answered,
   so the next chat can re-ask instead of guessing.
6. No secrets, ever. Keys, tokens, passwords, personal identifiers, and
   anything the user would not commit to a public repo stay out, because
   pills get committed to public repos. If a credential matters
   operationally, describe where it lives ("API key stored on the machine at
   path P"), never its value.
7. Date the pill, name the source chat, and list the sources it was written
   from (the live conversation, delivered artifacts, prior documents).
8. Regenerate from the live chat at each milestone, not only at the end;
   a chat can hit its limit mid-task. When a prior pill exists, write the
   new one from the current conversation and diff against the old pill for
   anything real that would otherwise be lost; never chain pill-from-pill
   without checking against reality, because errors compound.

### Quality gate: the resume test

Before delivering, ask: could a fresh Claude holding only this pill, plus
the uploads it names as required, continue the work without asking the user
to re-explain anything? Walk each planned next step and check the pill
answers the questions that step raises. If any step would force a question
back to the user, the pill is not done.

### Delivery

One markdown file, named `<PROJECT>_HANDOFF_PILL.md`, delivered as a file
the user can download. Typical size is 150 to 400 lines; heavy engineering
chats justify up to about 600. Past that, split bulk reference material into
a companion file and keep the pill as the dense index that points to it.
Tell the user in one or two lines what the pill carries and what they must
upload alongside it next time. Do not paste the whole pill into the chat.

## INGEST mode

When a pill is uploaded or pasted at the start of a chat:

1. Read the entire pill before responding to anything else.
2. Confirm state back to the user in a few lines: the project, its current
   version or state, what was in flight, and the open questions awaiting
   their answer. This proves the load and surfaces staleness immediately.
3. Adopt the standing directives section as if the user had typed those
   instructions in this chat.
4. If the requested work needs artifacts the pill lists as required uploads
   and they are not present, ask for exactly those files by name before
   attempting the work.
5. Treat the pill as the most current source. Where it conflicts with an
   older document also in context, prefer the pill and flag the conflict in
   one line rather than silently picking.
6. Do not re-verify or re-derive what the pill states as settled unless
   evidence in the new chat contradicts it.
