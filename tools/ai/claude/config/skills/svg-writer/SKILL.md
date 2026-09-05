---
name: svg-writer
description: Use when writing or modifying SVG files.
---

# SVG Writer

## Overview

Write and lint SVG files consistent with my conventions.

SVG is a configuration language — no test workflow, no TDD.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `svg-lint --fix <file>` on any modified `.svg` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The SVG looks fine, no need to lint" | `svg-lint --fix` catches formatting issues you won't spot visually. Always lint. |
| "I'll fix the lint errors later" | Lint after every modification. Later never comes. |

## Checklist

- [ ] File is valid SVG
- [ ] `svg-lint --fix <file>` run, all violations fixed
