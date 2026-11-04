---
name: documentation-tighten
description: Use when the user wants to tighten, audit or proofread local Markdown documentation (a file or a directory). Runs one round. The Elephant (main agent) launches Goldfish sub-agents with zero context, which read only the docs and report findings, then the Elephant fixes the docs.
---

# Documentation Tighten

## Overview

One round of documentation tightening, based on the Elephant and Goldfish
pattern. The Elephant is the main agent. A Goldfish is a zero-context sub-agent
that reads only the docs and reports findings.

## Core Workflow

### Step 1 — Resolve the target

**Goal:** Know which docs the round covers.

**Exit criterion:** A list of absolute paths of local Markdown files is ready.

The skill edits local Markdown files only.

- Local Markdown file: the target is that file.
- Local directory: the target is every Markdown file under it, recursively.
- Anything else (a URL, a Confluence page, a pull request, a missing path, a
  directory with no Markdown file): stop and tell the user the skill needs local
  Markdown.
- No argument: ask the user. Do not infer one.

### Step 2 — Launch the Goldfish

**Goal:** Get a findings report from each Goldfish.

**Exit criterion:** Every Goldfish returned its report.

Use the `Agent` tool with the `general-purpose` subagent. Launch each Goldfish
with its fixed description, so the Claude Code statusline colors it. Every
`references/...` path of this skill is relative to the directory of this file.

| Goldfish        | Description              | Brief                                    |
| --------------- | ------------------------ | ---------------------------------------- |
| `contradiction` | `Goldfish contradiction` | `references/goldfishes/contradiction.md` |
| `glossary`      | `Goldfish glossary`      | `references/goldfishes/glossary.md`      |
| `gap`           | `Goldfish gap`           | `references/goldfishes/gap.md`           |
| `clarity`       | `Goldfish clarity`       | `references/goldfishes/clarity.md`       |
| `concision`     | `Goldfish concision`     | `references/goldfishes/concision.md`     |
| `summary`       | `Goldfish summary`       | `references/goldfishes/summary.md`       |

Launch every Goldfish in a single message, one `Agent` call each, so they run in
parallel. Wait for the report of every Goldfish before Step 3.

A Goldfish that errors, times out or returns a malformed report is a fatal
error. A report of a finding Goldfish (every Goldfish except `summary`) is
malformed when one of its findings has no severity or no quote. The report of
the `summary` Goldfish is malformed when it is empty.

A fatal error stops the round. Do not retry and do not continue the round. Keep
the edits already applied. Report the failure to the user first, with the name
of the Goldfish, command or script that failed and its error, so the user fixes
it before any result is used.

The prompt of a Goldfish holds exactly these parts, in this order:

1. The content of `references/goldfish.md`
2. The content of the Goldfish brief
3. The list of target doc paths

Add nothing else: no glossary, referenced file, conversation, user intent,
opinion of the docs or code path. The Goldfish finds its own context.

### Step 3 — Merge the findings

**Goal:** One list of findings, with no duplicate.

**Exit criterion:** Every defect appears once, with every quote that shows it.

Collect the findings of all Goldfish. Treat two findings as duplicates when they
share at least one quoted passage and a single edit of the doc would resolve
both, whatever the Goldfish axis. Merge each group of duplicates into one
finding:

- Keep the highest severity of the group.
- Keep every distinct quote.
- Keep the problem sentence that names the cause most precisely.
- Keep the `Proposed wording` of the clarity Goldfish, when the group has one.
- Keep the `Keep in` or `Shorter wording` of the concision Goldfish, when the
  group has one.

A Goldfish that reports its no-finding sentence reports zero findings: it adds
nothing to the list. When every Goldfish reports zero, the list is empty. Step 5
then calls the severity script with `0` for each count, and that outcome is
valid.

The summary Goldfish reports a summary, never a finding. Compare it to your own
reading of the docs:

1. Read the target docs yourself, before you open the summary. List the rules as
   you understand them.
2. Compare the summary to your list, rule by rule. A mismatch is a summary rule
   that differs in meaning from the doc, a summary rule the doc never states, or
   a doc rule the summary leaves out. A different wording with the same meaning
   is not a mismatch.
3. Write each mismatch as an ambiguity finding, in the shared format. Quote the
   doc passage. When the summary states a rule the doc never states, quote the
   nearest doc passage on the same subject. Add a `Summary` line with the
   summary bullet, or `omitted` when the summary leaves the rule out. In the
   problem sentence, say how the reader went wrong.
4. Give the finding `blocking` when the reader would do the wrong thing,
   otherwise `important`.
5. Add the finding to the list, then merge it by the duplicate rule above.

### Step 4 — Fix the docs

**Goal:** Apply the merged findings to the local Markdown files, in two phases:
the automatic fixes, then the manual fixes.

**Exit criterion:** Every finding is fixed, asked about, rejected with a reason
or `Ignored`. The recap of each phase is printed.

Phase 1 handles every finding that matches none of the three ask cases, whatever
its tier. Phase 2 handles the findings that match one.

Edit a Markdown file outside the target list only when it lies in the directory
of a target file or in a subdirectory of it. A finding that needs any other file
is `Ignored`, with the path of that file.

Go through the findings to fix, blocking first. For each finding:

1. Read the quoted passages in the doc, even if an earlier fix already read
   them. Reject the finding, with a reason, when an earlier fix made it obsolete
   ("already resolved by another fix") or when you judge it wrong. You hold more
   context than the Goldfish, so your judgment prevails.
2. Pick the fix. Follow the nearest `GLOSSARY.md`. `markdown-lint` checks the
   Markdown rules afterward.
3. Apply the fix with the `Edit` tool.

The ask cases are these three: two passages disagree and the nearest
`GLOSSARY.md` does not settle which is right, you cannot tell which of several
readings or meanings of a passage the docs intend, or a gap needs an answer that
neither the target docs, the nearest `GLOSSARY.md` nor a file the target docs
reference holds.

**Phase 1 — automatic fixes.** Fix every finding that matches no ask case,
blocking first, then important, then nitpick. Run the lint commands below, then
print the Phase 1 recap. When at least one finding matches an ask case, end the
message with the question "Continue with the manual fixes?". The user may commit
before the answer. When the user declines, the findings stay `Asked` and the
round ends.

**Phase 2 — manual fixes.** Ask the user about every finding that matches an ask
case, one question at a time, with your recommended answer. Show every quote of
the finding (both quotes for a disagreement) and offer the options. When the
answer to one question settles another finding, ask them as one question. The
user may skip a question: the finding moves to `Ignored`. Apply no fix before
the last answer. After the last answer, apply every matching fix with the `Edit`
tool, run the lint commands below, print the Phase 2 recap and end the round.
When the user ends the session without answering, the finding stays `Asked`.

A clarity finding lists competing readings and a proposed wording. Apply the
proposed wording when it keeps every rule of the passage. Otherwise write your
own wording that keeps every rule.

An ambiguity finding shows that a reader without context misreads a passage.
Reword the passage so that the rule you wrote in your own list (Step 3, item 1)
for that passage is its only possible reading.

A contradiction or glossary finding shows two passages, or a passage and a
glossary definition, that disagree. Keep the one that follows the nearest
`GLOSSARY.md` and fix the other to match it. With no `GLOSSARY.md`, or when it
is silent, the finding is an ask case: the user says which passage is right.

A concision finding names the place where a repeated rule stays. Keep the rule
there, and remove it from every other place, or replace it with a pointer to the
kept place. Before the removal, check that the kept place holds every detail of
the removed one, and move any missing detail there. For a verbose passage, apply
the `Shorter wording` when it keeps every rule of the passage.

A gap finding asks for an answer that the docs do not hold. Never invent the
answer. The code never supplies the answer: read it only to verify a fact that a
doc already states. Never cite a code path in the docs. When the code
contradicts the doc, the doc is right: do not change it to match the code.

At the end of each phase, run `markdown-fix <file>` then
`markdown-lint --fix <file>` on every file modified in that phase. A command
that exits with an error is a fatal error (see Step 2).

Write each recap in English. It lists only the fixes of its phase, ordered by
tier (blocking, important, nitpick), then grouped by theme, with what you
removed and what you changed. It lists no rejected, `Ignored` or `Asked`
finding.

### Step 5 — End the round

**Goal:** Give the user the outcome.

**Exit criterion:** The first and last messages carry one severity line.

The first message is the first assistant message of the round. It starts with
the severity line, followed by the Phase 1 recap. The last message is the Phase
2 recap, or the first message when no finding is `Asked` or the user declines
Phase 2. It ends with the severity line. Intermediate messages, such as one
question each, carry no severity line.

Write each line as `<initial> → <remaining>`. Get each part from the helper
`documentation-tighten-severity --blocking <n> --important <n> --nitpick <n>`,
which lies in PATH. The script prints the emoji and the label: for `0` in every
count, it prints `🟢 none`. A script that is missing, exits with an error or
prints nothing is a fatal error (see Step 2). Each time you write a severity
line, call it twice: once for the initial part and once for the remaining part.
Pass one count for each severity (`blocking`, `important`, `nitpick`) to its
flag:

- **Initial:** count the findings of the merged list from Step 3 (Goldfish
  findings and ambiguity findings), whatever their outcome (fixed, asked,
  rejected or `Ignored`).
- **Remaining:** count the findings with status `Asked` at the moment you write
  that line. Do not count `Ignored` findings.

A round that ends early (a Step 1 stop or any fatal error, whether it comes from
a Goldfish, a command or the severity script) carries no severity line.

Example: `🟠 important → 🟢 none`.

Stop there. Do not start a second round: one invocation is one round.

## Common Rationalizations

| Rationalization                                          | Reality                                                        |
| -------------------------------------------------------- | -------------------------------------------------------------- |
| "I'll give the Goldfish some context, it will find more" | Context is what hides defects. A reader without it finds them. |
| "The fixes changed the docs, I should run another round" | Stop after Step 5.                                             |
| "The Goldfish summarized it wrong, that is its fault"    | A wrong summary shows an ambiguous doc. Report the mismatch.   |
| "I'll read the summary first, then skim the docs"        | Step 3 sets the order. Else you only confirm the summary.      |

## Checklist

- [ ] Target resolved to local Markdown files, or the round stopped
- [ ] Goldfish launched and prompted as Step 2 says
- [ ] Duplicate findings merged before any fix
- [ ] Phase 1 fixed every finding that matches no ask case, whatever its tier
- [ ] Phase 1 recap printed in English, with the fixes only
- [ ] Phase 2 asked every question before any fix, then printed its recap
- [ ] Each repeated rule kept in one place, with no rule lost
- [ ] Own reading of the docs formed before reading the summary
- [ ] Each summary mismatch listed as an ambiguity finding
- [ ] User asked only as Step 4 says
- [ ] `markdown-fix` and `markdown-lint --fix` run on every modified file
- [ ] Severity lines written as Step 5 says
