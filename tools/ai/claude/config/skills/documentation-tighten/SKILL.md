---
name: documentation-tighten
description: Use when the user wants to tighten, audit or proofread documentation — a doc file or a directory of docs. Runs one round. The Elephant (main agent) launches Goldfish sub-agents with zero context, which read only the docs and report findings, then the Elephant fixes the docs.
---

# Documentation Tighten

## Overview

One round of documentation tightening, based on the Elephant and Goldfish
pattern. The Elephant is the main agent. A Goldfish is a zero-context sub-agent
that reads only the docs and reports findings. One invocation runs one round.
There is no cap, no loop and no stop rule.

## Core Workflow

### Step 1 — Resolve the target

**Goal:** Know which docs the round covers.

**Exit criterion:** A list of absolute doc paths is ready.

The argument is the path of a doc file or a directory.

- File: the target is that file.
- Directory: the target is every Markdown file under it, recursively.
- No argument: ask the user for a path. Do not infer one.

### Step 2 — Launch the Goldfish

**Goal:** Get a findings report from a Goldfish that has no context.

**Exit criterion:** The Goldfish returned its report.

Use the `Agent` tool with the `general-purpose` subagent. Launch each Goldfish
with its fixed description, so the Claude Code statusline colors it.

| Goldfish        | Description              | Brief                                    |
| --------------- | ------------------------ | ---------------------------------------- |
| `contradiction` | `Goldfish contradiction` | `references/goldfishes/contradiction.md` |

The prompt of a Goldfish holds exactly these parts, in this order:

1. The content of `references/goldfish.md`
2. The content of the Goldfish brief
3. The list of target doc paths

Do not add the conversation, the intent of the user, your own opinion of the
docs or any code path. A Goldfish with context is not a Goldfish.

### Step 3 — Fix the docs

**Goal:** Apply every finding to the docs.

**Exit criterion:** Every finding is fixed, asked about or dismissed with a
reason.

Go through the findings, blocking first. For each finding:

1. Read the quoted passages in the doc. Reject the finding when it has no
   severity, no quote, or a quote that does not match the doc, and say why.
2. Pick the fix. Follow the nearest `GLOSSARY.md` and the Markdown conventions.
3. Apply the fix with the `Edit` tool.

Ask the user before the edit only when the fix changes the meaning of a rule:
two passages disagree, and choosing one changes what a reader must do. Show both
quotes and offer the options. Fix the other findings without asking.

Run `markdown-fix <file>` then `markdown-lint --fix <file>` on every modified
file.

### Step 4 — End the round

**Goal:** Give the user the outcome in one line.

**Exit criterion:** The last line of the reply gives the highest severity found.

Write the last line of the reply as `Highest severity: <level>`, with `<level>`
one of `blocking`, `important`, `nitpick` or `none`. It is the highest severity
the Goldfish reported, whatever the fix outcome. Stop there. Do not start a
second round.

## Common Rationalizations

| Rationalization                                          | Reality                                                        |
| -------------------------------------------------------- | -------------------------------------------------------------- |
| "I'll give the Goldfish some context, it will find more" | Context is what hides defects. A reader without it finds them. |
| "The fixes changed the docs, I should run another round" | One invocation is one round. The user decides on the next.     |
| "The finding is wrong, I'll skip it silently"            | Reject it with a reason, in the reply.                         |
| "Both passages are fine, I'll pick one and move on"      | A fix that changes a rule needs the user. Ask.                 |
| "The Goldfish could fix the typo itself"                 | A Goldfish never edits. The Elephant owns every edit.          |

## Checklist

- [ ] Target resolved from the path argument, or asked for
- [ ] Goldfish launched with the description `Goldfish contradiction`
- [ ] Prompt holds only the shared rules, the brief and the doc paths
- [ ] Every finding fixed, asked about or rejected with a reason
- [ ] User asked only for fixes that change the meaning of a rule
- [ ] `markdown-fix` and `markdown-lint --fix` run on every modified file
- [ ] Last line is `Highest severity: <level>`
- [ ] No second round started
