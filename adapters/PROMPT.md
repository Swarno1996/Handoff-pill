# Handoff Pill: paste-in prompts for any chat app

For chat apps without skill support (ChatGPT, Gemini, Copilot chat, Le
Chat, local models). Two prompts: one to make the pill in the old chat, one
to load it in the new chat.

## 1. In the long chat: make the pill

```
Create a handoff pill: one markdown file that lets a brand new chat continue
this work with no re-explaining, as if it were this chat's environment
rebuilt from an image.

Start with a fenced yaml manifest beginning "pill: 2" listing what the new
chat must restore: platform and model; tools, plugins, connectors or custom
GPTs/Gems used; packages installed in the code sandbox (with the exact
install command); repos and commits; files I uploaded or you produced that
are needed again; env var names (never values). Every entry gets a
"restore" line: an exact command, or the exact thing I must do.

Then these sections, dense and exact, not narrative:
critical operational facts (what does not carry over, which files I must
re-upload for which work); what the project is; current state with exact
numbers and versions; artifact inventory; how to work (exact steps);
environment sharp edges; casebook of every non-obvious problem solved
(symptom, root cause, fix); my standing instructions at full strength;
state of play with open questions word for word; roadmap; how to resume.

No secrets. Before giving it to me, check: could a fresh chat with only this
file do every next step without asking me to re-explain? Fix gaps first.
Give it to me as a downloadable file named <PROJECT>_HANDOFF_PILL.md, or if
you cannot make files, as one markdown code block.
```

## 2. In the new chat: load the pill

```
This is a handoff pill from a previous chat. Read all of it before
answering. Then:
1. Compare its manifest with what you have here and show me a short table:
   item, present / missing / not available here, what to do.
2. Do not run any install or command until I approve.
3. After restoring, confirm in a few lines: the project, its current state,
   what was in flight, and the open questions waiting for me.
4. Follow the standing instructions in it as if I had typed them here.
```
