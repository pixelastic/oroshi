---
name: blog-writer
description: Use when the user wants to write a short technical blog article from real work — code, a worktree, a branch, a PRD or a bare topic. Interviews the user, validates a Brief, writes an English Markdown Draft, lints it and has three Reviewers check it.
---

# Blog Writer

## Overview

Turn real work into a short technical article in English. The skill reads the **Source material**, interviews the user, validates a **Brief**, writes a **Draft** in an **Article folder**, lints it, has three **Reviewers** check it, and stops when the user approves.

Vocabulary: use the terms of `GLOSSARY.md` (Reader, Voice, Structure, Style, Brief, Article folder, Draft, Interview, Source material, Lint, Reviewer, Improvement, Nitpick). Do not use the words listed under `_Avoid_`.

The user speaks French or English. Every written artifact is in English, except the interview verbatim.

## Core Workflow

### Step 1 — Start

**Goal:** Create or reopen the Article folder.

**Exit criterion:** `blog-writer-start` returned its JSON and you hold the paths `folder`, `brief`, `interview`, `draft` and `images`.

1. Choose a short kebab-case slug from the topic. Ask the user only when the topic is unclear.
2. Run `blog-writer-start <slug>` and parse the JSON output.
3. Starting an existing slug reopens it. Read the files already there (`brief.md`, `interview.md`, `draft.md`) and resume at the first step whose output is missing.

### Step 2 — Gather facts

**Goal:** Learn everything the Source material can tell before asking the user anything.

**Exit criterion:** You hold the facts (errors, versions, snippets, decisions, rejected alternatives) and a list of what the material cannot answer.

1. Read the Source material the user points to: files, a worktree, a branch, a PRD and its issues (`plan-directory` finds them), several worktrees. A bare topic has no Source material: go to Step 3.
2. Note facts with their exact wording: error messages, version numbers, code snippets.
3. List the gaps: the why, the background, what the user felt. These are the only subjects of the Interview.
4. Do not read Claude session transcripts as Source material.

### Step 3 — Interview

**Goal:** Learn from the user what the Source material cannot tell.

**Exit criterion:** Enough is known to write a Brief, or the user stops the Interview.

Read `references/interview.md` and follow it: one question per turn, open then focused then closed, 5 to 10 questions as a soft cap, the user may stop at any time.

Append each question and answer verbatim to the `interview` path.

### Step 4 — Brief

**Goal:** Get a validated Brief before any drafting.

**Exit criterion:** The user validated the Brief, saved at the `brief` path.

1. Read `references/reader.md` and `references/brief.md`.
2. Write the Brief in English. A Brief covers exactly one article.
3. Estimate the prose length from the Interview and the Source material.
4. If the estimate exceeds 2000 prose words, do not write a Brief yet. Propose a split into standalone articles, each with its own Brief and Article folder. Wait for the user's decision. Write one Brief per article, and run Step 1 for each additional slug.
5. Show the Brief. Apply the user's changes. Repeat until the user validates it.

### Step 5 — Images

**Goal:** Save every image of the article in the `images` folder, named from its meaning.

**Exit criterion:** Each image the user gave is a file in the `images` folder, and you hold its name and its alt text.

Skip this step when the user gave no image. Read `references/images.md`. Run this step each time the user gives an image, at any point of the session: a pasted image must be copied in the same turn.

1. Ask once, before the Draft, whether the article needs images. Do not insist.
2. For an image URL, download it into the `images` folder. For a pasted image, copy it from the path of its `[Image: source: ...]` block. When that block is missing, ask the user for a path or a URL.
3. Name the file from what it shows. Never overwrite an existing file.
4. Look at the image and write its alt text.
5. Never generate or edit an image.

### Step 6 — Write the Draft

**Goal:** Write the Draft in English, following the Brief and the Style.

**Exit criterion:** The Draft is saved at the `draft` path.

1. Read `references/draft-format.md`.
2. Read the style references that exist: `references/style.md`, `references/voice.md`, `references/structure.md`. Missing files are pending. Tell the user which are pending, then write without them.
3. Write in English, whatever language the user speaks, including quotes from the French Interview.
4. Link each image of the `images` folder with a relative path and its alt text, where the text needs it.
5. Write the file with the Write tool, or Edit when the file exists.

### Step 7 — Lint

**Goal:** Remove every mechanical violation.

**Exit criterion:** `blog-lint` reports zero errors, and every image link points to an existing file and has an alt text.

1. Run `blog-lint <draft>`. It prints a JSON array of violations with `line`, `rule`, `severity`, `match` and `message`.
2. Fix each error with the Edit tool.
3. A violation with the rule `blog.WordLimit` means the Draft is too long. Do not trim blindly: go back to Step 4 and propose a split.
4. Run the link check of `references/images.md`. Fix each broken link or empty alt text: rename the link, save the missing image (Step 5) or remove the link.
5. Run `blog-lint` and the link check again. Repeat until zero errors and zero broken links remain. Warnings may stay when justified.

### Step 8 — Review

**Goal:** Fix what the Lint cannot see, before the user reads the Draft.

**Exit criterion:** Every Improvement is applied, `blog-lint` reports zero errors and the link check reports zero broken links.

1. Send a single message with 3 Agent tool calls, one per Reviewer. Use the `general-purpose` subagent type for each.
2. Each prompt includes the absolute `draft` path and tells the Reviewer to:
   - read the Draft;
   - read its own reference file from the table below, and `references/review-format.md`, and nothing else;
   - check the Draft against its axis only;
   - return findings in the format of `references/review-format.md`, or `No findings.`
3. The Reader Reviewer prompt also states the Reader of the Brief when the Brief overrides the default Reader, in one sentence.
4. A style reference marked pending in Step 6 has no Reviewer. Skip it and tell the user.
5. Present each report under its own heading, in this order: `## Voice`, `## Structure`, `## Reader`. Do not merge or rerank the axes.
6. Keep only the Improvements. Hide the Nitpicks. An out-of-axis finding stays in the report of the Reviewer who raised it, and follows the same rule.
7. Apply each Improvement with the Edit tool. Locate the place from the quote. When two Improvements contradict, keep the one that follows the Voice, and tell the user.
8. Run `blog-lint <draft>` and the link check again. Fix each error and each broken link. Repeat until none remain.
9. End with a one-line summary: Improvements per axis, then the total, then "(N nitpicks hidden)".

| Reviewer | Reference file |
|---|---|
| Voice | `references/voice.md` |
| Structure | `references/structure.md` |
| Reader | `references/reader.md` |

Only when the harness has no sub-agents: run the three axes one after the other, each with its own notes, as if each were a separate Reviewer. Do not carry findings from one axis into the next.

### Step 9 — Show the Draft

**Goal:** Let the user read the Draft and decide.

**Exit criterion:** The user approves the Draft, or asks for changes.

1. Display the Draft from the `draft` path, and its word count from `markdown-wordcount <draft>`.
2. Ask the user to approve or to request changes.
3. Change requests: go back to Step 6, then run Step 7 again.
4. Approval: the skill ends. Do not copy the Draft to the clipboard. Do it only on request, with `clipboard-write`. Save to another path only on request.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user speaks French, I'll write the Draft in French" | The output is English only. The user's language is not a signal. |
| "I can ask the user for the facts, it is faster" | Read the Source material first. Ask only the why and the background. |
| "I'll ask three questions at once to save turns" | One question per turn. |
| "The Brief is obvious, I'll start drafting" | No Draft without a validated Brief. |
| "It is 2100 words, I'll trim a bit" | Over 2000 prose words, propose a split. Do not cut. |
| "Lint warnings are noise" | Fix errors until zero. Keep a warning only when justified. |
| "The user will want it in the clipboard" | Copy only on request. |
| "I'll link the first article for background" | Every article stands alone. Recap what it assumes. |
| "Style references are missing, I'll invent a Voice" | Tell the user they are pending. Write plainly with simple words. |
| "I can review the three axes myself in one pass" | Each Reviewer needs an isolated context. Send the three Agent calls in one message. |
| "A Reviewer found nothing, so it skipped the job" | A Reviewer may report nothing. Do not ask for findings. |
| "The Nitpicks are cheap, I'll fix them too" | Apply only Improvements. Report the hidden Nitpick count. |
| "The edits are small, no need to lint again" | Improvements can break the Lint. Run `blog-lint` again. |
| "The pasted image path is in /tmp, I'll copy it later" | `/tmp` is cleaned. Copy the image in the same turn as the paste. |
| "I'll rebuild the pasted image path from the session id" | Read the path in the `[Image: source: ...]` block. Never rebuild it. |
| "`1.png` is fine as a file name" | Name the file from what it shows. |
| "The alt text can repeat the file name" | Look at the image. Say what it shows and what to notice. |
| "The image is too big, I'll resize it" | The skill never edits an image. Tell the user. |
| "The link looks right, no need to check it" | Run the link check. A broken link must not reach the user. |

## Checklist

- [ ] `blog-writer-start` ran and returned the paths
- [ ] Source material read before the first question
- [ ] Interview: one question per turn, verbatim saved at the `interview` path
- [ ] Brief validated by the user, saved at the `brief` path
- [ ] Split proposed before drafting when the estimate exceeded 2000 prose words
- [ ] Each image saved in the `images` folder, named from its meaning, copied in the turn it was pasted
- [ ] Draft written in English at the `draft` path
- [ ] Pending style references reported to the user
- [ ] Every image has alt text written after looking at it
- [ ] `blog-lint` returns zero errors
- [ ] Link check reports zero broken links and zero empty alt texts
- [ ] No image generated or edited
- [ ] Three Reviewers sent in a single message, each reading only its own reference plus `references/review-format.md`
- [ ] Only Improvements applied, hidden Nitpick count reported
- [ ] `blog-lint` and the link check pass after the Improvements
- [ ] User approved the Draft
- [ ] Clipboard untouched unless requested
