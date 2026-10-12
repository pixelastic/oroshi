---
name: blog-writer
description: Use when the user wants to write a short technical blog article from real work — code, a worktree, a branch, a PRD or a bare topic. Interviews the user, validates a Brief, writes an English Markdown Draft and lints it.
---

# Blog Writer

## Overview

Turn real work into a short technical article in English. The skill reads the **Source material**, interviews the user, validates a **Brief**, writes a **Draft** in an **Article folder**, lints it, and stops when the user approves.

Vocabulary: use the terms of `GLOSSARY.md` (Reader, Voice, Structure, Style, Brief, Article folder, Draft, Interview, Source material, Lint). Do not use the words listed under `_Avoid_`.

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

### Step 5 — Write the Draft

**Goal:** Write the Draft in English, following the Brief and the Style.

**Exit criterion:** The Draft is saved at the `draft` path.

1. Read `references/draft-format.md`.
2. Read the style references that exist: `references/style.md`, `references/voice.md`, `references/structure.md`. Missing files are pending. Tell the user which are pending, then write without them.
3. Write in English, whatever language the user speaks, including quotes from the French Interview.
4. Link the images already in the `images` folder with relative paths and an alt text.
5. Write the file with the Write tool, or Edit when the file exists.

### Step 6 — Lint

**Goal:** Remove every mechanical violation.

**Exit criterion:** `blog-lint` reports zero errors.

1. Run `blog-lint <draft>`. It prints a JSON array of violations with `line`, `rule`, `severity`, `match` and `message`.
2. Fix each error with the Edit tool.
3. A violation with the rule `blog.WordLimit` means the Draft is too long. Do not trim blindly: go back to Step 4 and propose a split.
4. Run `blog-lint` again. Repeat until zero errors remain. Warnings may stay when justified.

### Step 7 — Show the Draft

**Goal:** Let the user read the Draft and decide.

**Exit criterion:** The user approves the Draft, or asks for changes.

1. Display the Draft from the `draft` path, and its word count from `markdown-wordcount <draft>`.
2. Ask the user to approve or to request changes.
3. Change requests: go back to Step 5, then run Step 6 again.
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

## Checklist

- [ ] `blog-writer-start` ran and returned the paths
- [ ] Source material read before the first question
- [ ] Interview: one question per turn, verbatim saved at the `interview` path
- [ ] Brief validated by the user, saved at the `brief` path
- [ ] Split proposed before drafting when the estimate exceeded 2000 prose words
- [ ] Draft written in English at the `draft` path
- [ ] Pending style references reported to the user
- [ ] `blog-lint` returns zero errors
- [ ] User approved the Draft
- [ ] Clipboard untouched unless requested
