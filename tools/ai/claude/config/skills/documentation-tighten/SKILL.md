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

**Goal:** Get a findings report from each Goldfish, all running at once.

**Exit criterion:** Every Goldfish returned its report.

Use the `Agent` tool with the `general-purpose` subagent. Launch each Goldfish
with its fixed description, so the Claude Code statusline colors it.

| Goldfish        | Description              | Brief                                    |
| --------------- | ------------------------ | ---------------------------------------- |
| `contradiction` | `Goldfish contradiction` | `references/goldfishes/contradiction.md` |
| `glossary`      | `Goldfish glossary`      | `references/goldfishes/glossary.md`      |
| `gap`           | `Goldfish gap`           | `references/goldfishes/gap.md`           |
| `clarity`       | `Goldfish clarity`       | `references/goldfishes/clarity.md`       |

Launch every Goldfish in a single message with one `Agent` call each, so they
run in parallel. Never launch them one after another.

The prompt of a Goldfish holds exactly these parts, in this order:

1. The content of `references/goldfish.md`
2. The content of the Goldfish brief
3. The list of target doc paths

The Goldfish finds the nearest `GLOSSARY.md` and follows the references of the
docs by itself. Do not read them for it, and do not paste them into the prompt.

Do not add the conversation, the intent of the user, your own opinion of the
docs or any code path. A Goldfish with context is not a Goldfish.

### Step 3 — Merge the findings

**Goal:** One list of findings, with no duplicate.

**Exit criterion:** Every defect appears once, with every quote that shows it.

Collect the findings of all Goldfish. Treat two findings as duplicates when they
share at least one quoted passage and name the same defect. Merge each group of
duplicates into one finding:

- Keep the highest severity of the group.
- Keep every distinct quote.
- Keep the problem sentence that names the cause most precisely.
- Keep the `Proposed wording` of the clarity Goldfish, when the group has one.

A Goldfish that reports its no-finding sentence adds nothing to the list.

The gap Goldfish also reports an implementability verdict. It is not a finding.
Do not merge it. Keep it, with its list of missing items, for Step 5.

### Step 4 — Fix the docs

**Goal:** Apply every merged finding to the docs.

**Exit criterion:** Every finding is fixed, asked about or dismissed with a
reason.

Go through the merged findings, blocking first. For each finding:

1. Read the quoted passages in the doc. Reject the finding when it has no
   severity, no quote, or a quote that does not match the doc, and say why.
2. Pick the fix. Follow the nearest `GLOSSARY.md` and the Markdown conventions.
3. Apply the fix with the `Edit` tool.

Ask the user before the edit only when the fix changes the meaning of a rule:
two passages disagree, and choosing one changes what a reader must do. Show both
quotes and offer the options. Fix the other findings without asking.

A clarity finding lists competing readings and a proposed wording. Apply the
proposed wording when it keeps the meaning the docs clearly intend. Ask the user
when the readings lead to different actions and no passage says which one is
meant.

A gap finding asks for an answer that the docs do not hold. Never invent the
answer. Ask the user, unless the project files or a referenced file hold it.

Run `markdown-fix <file>` then `markdown-lint --fix <file>` on every modified
file.

### Step 5 — End the round

**Goal:** Give the user the verdict and the outcome.

**Exit criterion:** The last line of the reply gives the highest severity found.

Copy the `**Verdict:**` of the gap Goldfish into the reply, as
`Implementation: can implement` or `Implementation: cannot implement`. After
`cannot implement`, list the missing items the Goldfish gave. The verdict is the
one the Goldfish reported, whatever the fix outcome.

Write the last line of the reply as `Highest severity: <level>`, with `<level>`
one of `blocking`, `important`, `nitpick` or `none`. It is the highest severity
any Goldfish reported, whatever the fix outcome. Stop there. Do not start a
second round.

## Common Rationalizations

| Rationalization                                          | Reality                                                          |
| -------------------------------------------------------- | ---------------------------------------------------------------- |
| "I'll give the Goldfish some context, it will find more" | Context is what hides defects. A reader without it finds them.   |
| "The fixes changed the docs, I should run another round" | One invocation is one round. The user decides on the next.       |
| "The finding is wrong, I'll skip it silently"            | Reject it with a reason, in the reply.                           |
| "Both passages are fine, I'll pick one and move on"      | A fix that changes a rule needs the user. Ask.                   |
| "The Goldfish could fix the typo itself"                 | A Goldfish never edits. The Elephant owns every edit.            |
| "I'll launch the Goldfish one by one"                    | One message, all Goldfish. They run in parallel.                 |
| "Two Goldfish found it, I'll fix it twice"               | Merge duplicates first. One defect is one fix.                   |
| "I'll paste the glossary into the prompt to help"        | The Goldfish finds its own glossary. Pasting adds context.       |
| "The gap is obvious, I'll write the missing answer"      | The docs lack it. Ask the user, or find it in a referenced file. |
| "I know which reading the author meant"                  | You are not a Goldfish. If the docs do not say, ask the user.    |

## Checklist

- [ ] Target resolved from the path argument, or asked for
- [ ] Goldfish launched in one message, each with its `Goldfish <axis>`
      description
- [ ] Prompt holds only the shared rules, the brief and the doc paths
- [ ] Duplicate findings merged before any fix
- [ ] Every finding fixed, asked about or rejected with a reason
- [ ] User asked only for fixes that change the meaning of a rule
- [ ] `markdown-fix` and `markdown-lint --fix` run on every modified file
- [ ] Reply gives the implementability verdict, with the missing items after
      `cannot implement`
- [ ] Last line is `Highest severity: <level>`
- [ ] No second round started
