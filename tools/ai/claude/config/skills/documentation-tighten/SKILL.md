---
name: documentation-tighten
description: Use when the user wants to tighten, audit or proofread local Markdown documentation (a file). Runs one round: Goldfish sub-agents with zero context report findings, then the main agent fixes the docs.
---

# Documentation Tighten

## Overview

One round of documentation tightening, based on the Elephant and Goldfish
pattern. The Elephant is the main agent. A Goldfish is a zero-context sub-agent
that reads only the docs, the nearest `GLOSSARY.md` and the files the docs
reference, and reports findings.

## Core Workflow

### Step 1 — Resolve the target

**Goal:** Know which docs the round covers.

**Exit criterion:** A list of absolute paths of local Markdown files is ready.

The user may pass several paths. The target is the union of their targets. The
Elephant resolves a relative path from the working directory.

- Local Markdown file (`.md` extension): the target is that file.
- Anything else (a URL, a Confluence page, a pull request, a missing path, a
  directory, a file without the `.md` extension): stop and tell the user the
  skill needs a local Markdown file. One such path stops the round, even when
  other paths are valid.
- No argument: ask the user. Do not infer one.

### Step 2 — Launch the Goldfish

**Goal:** Get a findings report from each Goldfish.

**Exit criterion:** Every Goldfish returned its report.

Use the `Agent` tool with the `general-purpose` subagent. Every `references/...`
path of this skill is relative to the directory of this file.

| Goldfish        | Description              | Brief                                    |
| --------------- | ------------------------ | ---------------------------------------- |
| `contradiction` | `Goldfish contradiction` | `references/goldfishes/contradiction.md` |
| `glossary`      | `Goldfish glossary`      | `references/goldfishes/glossary.md`      |
| `gap`           | `Goldfish gap`           | `references/goldfishes/gap.md`           |
| `clarity`       | `Goldfish clarity`       | `references/goldfishes/clarity.md`       |
| `concision`     | `Goldfish concision`     | `references/goldfishes/concision.md`     |
| `summary`       | `Goldfish summary`       | `references/goldfishes/summary.md`       |

Launch every Goldfish in a single message, one `Agent` call each, so they run in
parallel. Give each its fixed description, so the Claude Code statusline colors
it.

A Goldfish that errors, times out or returns a malformed report is a fatal
error. An empty report is malformed. The report of a finding Goldfish (every
Goldfish except `summary`) is also malformed when one of its findings has no
quote or a severity other than `blocking`, `important` or `nitpick`.

A fatal error stops the round: do not retry, and keep the edits already applied.
Report the failure to the user before any other output, with the name of the
Goldfish or command that failed and its error, so the user fixes it before any
result is used.

The prompt of a Goldfish holds exactly these parts, in this order:

1. The content of `references/goldfish.md`
2. The content of the Goldfish brief
3. The list of target doc paths

Add nothing else (no glossary, referenced file, conversation, user intent,
opinion of the docs or code path): the Goldfish finds its own context.

### Step 3 — Merge the findings

**Goal:** One list of findings, with no duplicate.

**Exit criterion:** Every defect appears once, with every quote that shows it.

Collect the findings of all Goldfish. Treat two findings as duplicates when they
share at least one quoted passage and a single edit of the doc would resolve
both, whatever the Goldfish axis. Merge each group of duplicates into one
finding:

- Keep the highest severity of the group.
- Keep every distinct quote.
- Keep the problem sentence of the Goldfish whose axis names the kind of the
  defect: clarity for a passage open to two readings, contradiction for two
  passages that disagree, gap for a missing answer, concision for a repeated
  rule or a verbose passage, glossary for a term that breaks its definition.
  When several match, keep the one with the highest severity.
- Keep the `Proposed wording` of the clarity Goldfish, when the group has one.
- Keep the `Keep in` or `Shorter wording` of the concision Goldfish, when the
  group has one. When the group also has a `Proposed wording`, the
  `Proposed wording` guides the fix, and the `Shorter wording` applies only when
  the `Shorter wording` keeps every rule of the `Proposed wording`.

A no-finding sentence adds nothing to the list. When every Goldfish reports
zero, or when you reject every finding in Step 4, tell the user the docs hold no
finding.

When the list holds only nitpicks, the docs have reached the stop point of the
Elephant and Goldfish pattern: further rounds return only nitpicks. Tell the
user that only nitpicks remain and that another round is not worth it. Then go
to Step 4.

The summary Goldfish reports a summary, never a finding. Compare it to your own
reading of the docs:

1. Read the target docs yourself, before you open the summary. List the rules as
   you understand them.
2. Compare the summary to your list, rule by rule. A mismatch is a summary rule
   that differs in meaning from the doc, a summary rule the doc never states, or
   a doc rule the summary leaves out. A different wording with the same meaning
   is not a mismatch.
3. Write each mismatch as an ambiguity finding, in the finding format of
   `references/goldfish.md`. Quote the doc passage. When the summary states a
   rule the doc never states, quote the nearest doc passage on the same subject.
   Add a `Summary` line with the summary bullet, or `omitted` when the summary
   leaves the rule out. In the problem sentence, say how the reader went wrong.
4. Give the finding `blocking` when the reader would do the wrong thing,
   otherwise `important`.
5. Add the finding to the list, then merge it by the duplicate rule above.

### Step 4 — Fix the docs

**Goal:** Apply the merged findings to the local Markdown files, in two phases:
the automated fixes, then the human fixes.

**Exit criterion:** Every finding is fixed, asked about, rejected or `Ignored`.
The recap of each phase with a fix is printed.

The phases and the statuses `Asked` and `Ignored` are internal. Never write the
words "Phase", `Asked` or `Ignored` to the user.

Edit a Markdown file outside the target list only when it lies in the directory
of a target file or in a subdirectory of that directory.

Within each phase, fix the findings in this order: blocking, important, nitpick.
For each finding:

1. Read the quoted passages in the doc, even if an earlier fix already read
   them. Reject the finding when an earlier fix made it obsolete ("already
   resolved by another fix") or when you judge it wrong. You hold more context
   than the Goldfish, so your judgment prevails.
2. Pick the fix. Follow the nearest `GLOSSARY.md` of the doc you edit: the first
   one found when searching upward from the directory of that doc.
3. Apply the fix with the `Edit` tool. Human fixes delay this step (see below).

The ask cases are these four:

1. Two passages disagree and the nearest `GLOSSARY.md` does not settle which one
   is right.
2. You cannot tell which of several readings or meanings of a passage the docs
   intend.
3. A gap needs an answer that is in none of the target docs, the nearest
   `GLOSSARY.md` and the files the target docs reference.
4. The fix needs to edit a Markdown file that is neither in the target list nor
   in the directory of a target file or a subdirectory of that directory.

#### Automated fixes

Fix every finding that matches no ask case, of any severity, in the order set
above. A nitpick that matches an ask case is never asked: it moves to `Ignored`.
Run the end-of-phase commands (see "Fix rules"), then print the recap of the
Automated fixes phase. Let <n> be the number of questions Human fixes will ask:
one question per group of ask-case findings that one answer settles. When <n> is
at least 1, append "I have <n> unanswered questions. May I ask them?" to the
message that holds the recap, or send it alone when the phase has no recap. Then
wait for the answer. The user may commit meanwhile. When the user declines, the
round ends.

#### Human fixes

Ask the user about every finding that matches an ask case, except nitpicks, one
question at a time. Show every quote of the finding (both quotes for a
disagreement). Give one concrete example that shows the problem: a realistic
case where the passage leads a reader to two different actions. Offer the
candidate answers, one per competing reading, meaning or fix, and mark your
recommended one. Name the path of any file outside the target list. When the
answer to one finding also settles another finding, ask one question that covers
both findings. The user may skip a question: the finding moves to `Ignored`.
Apply the fix of an answered finding only after the last answer, and apply no
fix of a skipped finding. After the last answer, run the end-of-phase commands
(see "Fix rules"), print the recap of the Human fixes phase and end the round. A
finding the user leaves unanswered, by declining to be asked or by ending the
session, stays `Asked`.

#### Fix rules

A clarity finding lists competing readings and a proposed wording. Apply the
proposed wording when it keeps every rule of the passage. Otherwise write your
own wording that keeps every rule.

An ambiguity finding shows that a reader without context misreads a passage.
Reword the passage so that the rule you wrote in your own list (Step 3, item 1)
for that passage is its only possible reading.

A contradiction or glossary finding shows two passages, or a passage and a
glossary definition, that disagree. Keep the one that follows the nearest
`GLOSSARY.md` and fix the other to match it.

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
`markdown-lint --fix <file>` on every file modified in that phase. A failing
command is a fatal error (see Step 2).

Print no recap for a phase with no fix, nor in a message that holds only a
question. Write each recap in English. It lists only the fixes of its phase, in
one section per severity. Each section header holds the severity emoji, the
severity name and the number of fixes: `🔴 Blocking (n)`, `🟠 Important (n)`,
`🟢 Nitpick (n)`. Omit a severity with no fix. Each section groups its fixes by
the doc passage or topic they touch, with what you removed and what you changed.
It lists no rejected, `Ignored` or `Asked` finding.

### Step 5 — End the round

**Goal:** Give the user the outcome.

**Exit criterion:** The user holds every recap printed.

Stop after the last recap. One invocation is one round.

## Common Rationalizations

| Rationalization                                          | Reality                                                        |
| -------------------------------------------------------- | -------------------------------------------------------------- |
| "I'll give the Goldfish some context, it will find more" | Context is what hides defects. A reader without it finds them. |
| "The fixes changed the docs, I should run another round" | Stop after Step 5.                                             |
| "The Goldfish summarized it wrong, that is its fault"    | A wrong summary shows an ambiguous doc. Report the mismatch.   |
| "I'll read the summary first, then skim the docs"        | Step 3 sets the order. Else you only confirm the summary.      |
