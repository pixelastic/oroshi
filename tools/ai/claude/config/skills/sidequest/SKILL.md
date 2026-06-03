---
name: sidequest
description: Compact the current conversation into a sidequest document to launch a focused sub-conversation branched from the current one.
argument-hint: "What is the sidequest focused on?"
---

Derive a 3–5 word kebab-case slug from the conversation content (or from the
argument if provided). Write the sidequest document to
`/tmp/oroshi/claude/sidequests/<slug>.md`, creating the directory with
`mkdir -p` if needed (read the file before you write to it).

Suggest the skills to be used, if any, by the next session.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs,
issues, commits, diffs). Reference them by path or URL instead.

If the user passed arguments, treat them as a description of what the sidequest
will focus on and tailor the doc accordingly.

Once the file is written, run `sidequest-end <path>` (passing the actual file
path). This copies the launch command to the clipboard so the user can paste it
into a terminal to start a fresh Claude session with the sidequest as context.
