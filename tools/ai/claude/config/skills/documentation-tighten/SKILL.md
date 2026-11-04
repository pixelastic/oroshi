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
with its fixed description, so the Claude Code statusline colors it.

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
share at least one quoted passage and describe the same defect of the doc,
whatever the Goldfish axis. Merge each group of duplicates into one finding:

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
   doc passage. Add a `Summary` line with the summary bullet, or `omitted` when
   the summary leaves the rule out. In the problem sentence, say how the reader
   went wrong.
4. Give the finding `blocking` when the reader would do the wrong thing,
   otherwise `important`.
5. Add the finding to the list, then merge it by the duplicate rule above.

### Step 4 — Fix the docs

**Goal:** Apply the merged findings of the highest severity tier to the local
Markdown files.

**Exit criterion:** Every finding of the highest tier is fixed, asked about,
rejected with a reason or `Ignored`. The recap is printed.

Fix every merged finding of the highest tier present (`blocking`, then
`important`, then `nitpick`), to keep the diff readable. Mark every finding of a
lower tier `Ignored`.

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

Fix every finding that matches none of the four cases listed in the next
paragraph. Print the recap, then ask the user about the findings that match one.

Ask the user only in these four cases: two passages disagree, the readings of a
passage lead to different actions, you cannot tell which meaning the docs
intend, or a gap needs an answer the docs do not hold. Ask through `/grill-me`:
one question at a time, with your recommended answer. Show both quotes and offer
the options. When the answer to one question settles another finding, ask them
as one question. After each answer, apply the matching fix with the `Edit` tool
before you ask the next question. A question without its fix is not finished.
The user may skip a question: the finding moves to `Ignored`, and you ask the
next question.

A clarity finding lists competing readings and a proposed wording. Apply the
proposed wording when it keeps every rule of the passage. Otherwise write your
own wording that keeps every rule, or ask the user when you cannot tell which
meaning the docs intend.

An ambiguity finding shows that a reader without context misreads a passage.
Reword the passage so that the meaning you listed in Step 3, item 1 is the only
possible reading.

A concision finding names the place where a repeated rule stays. Keep the rule
there, and remove it from every other place, or replace it with a pointer to the
kept place. Before the removal, check that the kept place holds every detail of
the removed one, and move any missing detail there. For a verbose passage, apply
the `Shorter wording` when it keeps every rule of the passage.

A gap finding asks for an answer that the docs do not hold. Never invent the
answer. Ask the user, unless the nearest `GLOSSARY.md` or a file the target docs
reference holds it. You may read the code to check a fact when a finding raises
a question or an omission. Never cite a code path in the docs. When the code
contradicts the doc, the doc is right: do not change it to match the code.

Run `markdown-fix <file>` then `markdown-lint --fix <file>` on every modified
file. A command that exits with an error is a fatal error (see Step 2).

Write the recap in English, with four groups, in this order. After the user
answers, apply the fixes and print again the groups that changed.

- `Asked`: the findings that wait for an answer of the user.
- `Fixed`: grouped by theme, with what you removed and what you changed.
- `Rejected`: one line per rejected finding, with the reason.
- `Ignored`: the findings you left for a next round.

### Step 5 — End the round

**Goal:** Give the user the outcome.

**Exit criterion:** The first message starts, and the last message ends, with
one severity line: the initial severity, an arrow, the remaining severity.

The first message is the first assistant message of the round. It starts with
the severity line, followed by the recap of Step 4. The last message is the one
after the user answered or skipped every question, or the first message when it
asks none. It ends with the severity line. Intermediate messages, such as one
question each, carry no severity line.

Write each line as `<initial> → <remaining>`. Get each part from the helper
`documentation-tighten-severity --blocking <n> --important <n> --nitpick <n>`,
which lies in PATH. The script prints the emoji and the label. A script that is
missing, exits with an error or prints nothing is a fatal error (see Step 2).
Each time you write a severity line, call it twice: once for the initial part
and once for the remaining part. Pass one count for each severity (`blocking`,
`important`, `nitpick`) to its flag:

- **Initial:** count the findings of the merged list from Step 3 (Goldfish
  findings and ambiguity findings), whatever their outcome (fixed, asked,
  rejected or `Ignored`).
- **Remaining:** count the findings with status `Asked` at the moment you write
  that line. Do not count `Ignored` findings.

A round that ends early (a Step 1 stop or a fatal Goldfish error) carries no
severity line.

Example: `🟠 important → 🟡 nitpick`.

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
- [ ] Every finding of the highest tier fixed, asked about, rejected with a
      reason or `Ignored`
- [ ] Recap printed in English, with `Asked`, `Fixed`, `Rejected` and `Ignored`
- [ ] Each repeated rule kept in one place, with no rule lost
- [ ] Own reading of the docs formed before reading the summary
- [ ] Each summary mismatch listed as an ambiguity finding
- [ ] User asked only as Step 4 says
- [ ] `markdown-fix` and `markdown-lint --fix` run on every modified file
- [ ] Severity lines written as Step 5 says
