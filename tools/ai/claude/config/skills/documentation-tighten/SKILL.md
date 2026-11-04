---
name: documentation-tighten
description: Use when the user wants to tighten, audit or proofread documentation, from any source (a doc file, a directory, a Confluence page, a pull request). Runs one round. The Elephant (main agent) launches Goldfish sub-agents with zero context, which read only the docs and report findings, then the Elephant fixes the docs.
---

# Documentation Tighten

## Overview

One round of documentation tightening, based on the Elephant and Goldfish
pattern. The Elephant is the main agent. A Goldfish is a zero-context sub-agent
that reads only the docs and reports findings. One invocation runs one round.
There is no loop. A round fixes the `blocking` and `important` findings, and the
user starts the next round.

## Core Workflow

### Step 1 — Resolve the target

**Goal:** Know which docs the round covers.

**Exit criterion:** A list of absolute paths of local Markdown files is ready.

The argument names the documentation. It can be any source: a file, a directory,
a Confluence page, a pull request, a URL. A Goldfish reads local Markdown files
only.

- Local Markdown file: the target is that file.
- Local directory: the target is every Markdown file under it, recursively.
- Any other source: retrieve it with the tool that fits, and write it as
  Markdown files in the scratchpad. The target is those files.
- No argument, or a source you cannot retrieve: ask the user. Do not infer one.

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
| `concision`     | `Goldfish concision`     | `references/goldfishes/concision.md`     |
| `summary`       | `Goldfish summary`       | `references/goldfishes/summary.md`       |

Launch every Goldfish in a single message with one `Agent` call each, so they
run in parallel. Never launch them one after another. Wait for the report of
every Goldfish before Step 3.

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
- Keep the `Keep in` or `Shorter wording` of the concision Goldfish, when the
  group has one.

A Goldfish that reports its no-finding sentence adds nothing to the list.

The gap Goldfish also reports an implementability verdict. It is not a finding.
Do not merge it. Keep it, with its list of missing items, for Step 5.

The summary Goldfish reports a summary, never a finding. Compare it to your own
reading of the docs:

1. Read the target docs yourself, before you open the summary. List the rules as
   you understand them.
2. Compare the summary to your list, rule by rule. A mismatch is a summary rule
   that differs in meaning from the doc, a summary rule the doc never states, or
   a doc rule the summary leaves out. A different wording with the same meaning
   is not a mismatch.
3. Write each mismatch as an ambiguity finding, in the shared format. Quote the
   doc passage. Add a `Summary` line with the summary bullet, or `omitted` when
   the summary leaves the rule out. In the problem sentence, say how the reader
   went wrong.
4. Give the finding `blocking` when the reader would do the wrong thing,
   otherwise `important`.
5. Add the finding to the list, then merge it by the duplicate rule above.

A summary that matches your reading adds no finding.

### Step 4 — Fix the docs

**Goal:** Apply the essential merged findings to the local Markdown files.

**Exit criterion:** Every `blocking` and `important` finding is fixed, asked
about or rejected with a reason. The recap is printed.

Fix the `blocking` and `important` findings. Fix a `nitpick` or a minor gap only
when no `blocking` or `important` finding is left. Every finding you leave alone
is `Ignored`.

Go through the findings to fix, blocking first. For each finding:

1. Read the quoted passages in the doc. Reject the finding when it has no
   severity, no quote, or a quote that does not match the doc, and say why.
2. Pick the fix. Follow the nearest `GLOSSARY.md` and the Markdown conventions.
3. Apply the fix with the `Edit` tool.

Fix the findings that need no opinion of the user first. Then print the recap,
as described below. Then ask the user about the others.

Ask the user only when the fix changes the meaning of a rule: two passages
disagree, and choosing one changes what a reader must do. Ask through
`/grill-me`: one question at a time, with your recommended answer. Show both
quotes and offer the options. When the answer to one question settles another
finding, ask them as one question.

A clarity finding lists competing readings and a proposed wording. Apply the
proposed wording when it keeps the meaning the docs clearly intend. Ask the user
when the readings lead to different actions and no passage says which one is
meant.

An ambiguity finding shows that a reader without context misreads a passage.
Reword the passage so the reading you hold is the only one. Ask the user when
you cannot tell which meaning the docs intend.

A concision finding names the place where a repeated rule stays. Keep the rule
there, and remove it from every other place, or replace it with a pointer to the
kept place. Before the removal, check that the kept place holds every detail of
the removed one, and move any missing detail there. After the fix, the rule
appears once and no rule is lost. For a verbose passage, apply the
`Shorter wording` when it keeps every rule of the passage.

A gap finding asks for an answer that the docs do not hold. Never invent the
answer. Ask the user, unless the project files or a referenced file hold it. You
may read the code to check a fact when a finding raises a question or an
omission. Never cite a code path in the docs. When the code contradicts the doc,
the doc is right: do not change it to match the code.

Run `markdown-fix <file>` then `markdown-lint --fix <file>` on every modified
file.

Write the recap in English, with three groups:

- `Fixed`: grouped by theme, with what you removed and what you changed.
- `Rejected`: one line per rejected finding, with the reason.
- `Ignored`: the findings you left for a next round.

### Step 5 — End the round

**Goal:** Give the user the verdict and the outcome.

**Exit criterion:** The last line of the reply gives the highest severity found.

The recap of Step 4 comes first in the reply. Then copy the `**Verdict:**` of
the gap Goldfish into the reply, as `Implementation: can implement` or
`Implementation: cannot implement`. After `cannot implement`, list the missing
items the Goldfish gave. The verdict is the one the Goldfish reported, whatever
the fix outcome.

Write the last line of the reply as `Highest severity: <level>`, with `<level>`
one of `blocking`, `important`, `nitpick` or `none`. It is the highest severity
of any Goldfish finding or ambiguity finding, whatever the fix outcome. Stop
there. Do not start a second round.

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
| "I'll delete the repeated rule, the other copy has it"   | Check the kept copy holds every detail first. Never lose a rule. |
| "The Goldfish summarized it wrong, that is its fault"    | A wrong summary shows an ambiguous doc. Report the mismatch.     |
| "I'll read the summary first, then skim the docs"        | Form your own reading first. Else you only confirm the summary.  |
| "I'll fix the nitpicks too, while I am here"             | Only when no `blocking` or `important` finding is left.          |
| "The code says otherwise, I'll change the doc"           | The doc is right. Use the code to check a fact, never to decide. |
| "I'll ask all the questions in one message"              | `/grill-me`: one question at a time, with a recommendation.      |

## Checklist

- [ ] Target resolved to local Markdown files, or the user asked for the source
- [ ] Goldfish launched in one message, each with its `Goldfish <axis>`
      description
- [ ] Prompt holds only the shared rules, the brief and the doc paths
- [ ] Duplicate findings merged before any fix
- [ ] Every `blocking` and `important` finding fixed, asked about or rejected
      with a reason
- [ ] Minor findings fixed only when no `blocking` or `important` is left
- [ ] Recap printed in English, with `Fixed`, `Rejected` and `Ignored`
- [ ] Each repeated rule kept in one place, with no rule lost
- [ ] Own reading of the docs formed before reading the summary
- [ ] Each summary mismatch listed as an ambiguity finding
- [ ] User asked only for fixes that change the meaning of a rule, through
      `/grill-me`
- [ ] `markdown-fix` and `markdown-lint --fix` run on every modified file
- [ ] Reply gives the implementability verdict, with the missing items after
      `cannot implement`
- [ ] Last line is `Highest severity: <level>`
- [ ] No second round started
