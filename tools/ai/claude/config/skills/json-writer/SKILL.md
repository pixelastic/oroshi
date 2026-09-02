---
name: json-writer
description: Use when writing or modifying JSON files.
---

# JSON Writer

## Overview

Write and lint JSON files consistent with my conventions.

JSON is a configuration language — no test workflow, no TDD.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `json-lint --fix <file>` on any modified `.json` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The JSON looks fine, no need to lint" | `json-lint --fix` catches formatting issues you won't spot visually. Always lint. |
| "I'll fix the lint errors later" | Lint after every modification. Later never comes. |

## Checklist

- [ ] File is valid JSON
- [ ] `json-lint --fix <file>` run, all violations fixed
