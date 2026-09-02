---
name: toml-writer
description: Use when writing or modifying TOML files.
---

# TOML Writer

## Overview

Write and lint TOML files consistent with my conventions.

TOML is a configuration language — no test workflow, no TDD.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `toml-lint --fix <file>` on any modified `.toml` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The TOML looks fine, no need to lint" | `toml-lint --fix` catches formatting issues you won't spot visually. Always lint. |
| "I'll fix the lint errors later" | Lint after every modification. Later never comes. |

## Checklist

- [ ] File is valid TOML
- [ ] `toml-lint --fix <file>` run, all violations fixed
