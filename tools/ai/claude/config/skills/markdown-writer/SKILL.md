---
name: markdown-writer
description: Use when writing or modifying Markdown files.
---

# Markdown Writer

## Overview

Write, format and lint Markdown files consistent with my conventions.

Markdown is a configuration language — no test workflow, no TDD.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Format

**Goal:** Wrap prose and normalize layout.

**Exit criterion:** `markdown-fix` ran on every modified file.

- Run `markdown-fix <file>` on any modified `.md` files
- Never wrap lines by hand. `markdown-fix` wraps prose at 80 columns.

### Step 3 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `markdown-lint --fix <file>` on any modified `.md` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization                              | Reality                                                                      |
| -------------------------------------------- | ---------------------------------------------------------------------------- |
| "The Markdown looks fine, no need to format" | `markdown-fix` rewraps prose in ways you won't spot visually. Always format. |
| "I'll wrap the lines myself"                 | Hand wrapping drifts from the Prettier config. Let `markdown-fix` do it.     |
| "I'll fix the lint errors later"             | Lint after every modification. Later never comes.                            |

## Checklist

- [ ] `markdown-fix <file>` run
- [ ] `markdown-lint --fix <file>` run, all violations fixed
