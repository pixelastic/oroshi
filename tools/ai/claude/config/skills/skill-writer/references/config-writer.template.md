# Config-Language Skill Template

Config languages (JSON, XML, YAML, TOML, etc.) share the same two-step workflow:
modify, then lint. No tests, no TDD — validation comes from the linter.

```markdown
---
name: {lang}-writer
description: Use when writing or modifying {LANG} files.
---

# {LANG} Writer

## Overview

Write and lint {LANG} files consistent with my conventions.

{LANG} is a configuration language — no test workflow, no TDD.

## Core Workflow

### Step 1 — Modify the file

**Goal:** Make the requested change.

**Exit criterion:** File has the intended content.

### Step 2 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `{lang}-lint --fix <file>` on any modified `.{ext}` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The {LANG} looks fine, no need to lint" | `{lang}-lint --fix` catches formatting issues you won't spot visually. Always lint. |
| "I'll fix the lint errors later" | Lint after every modification. Later never comes. |

## Checklist

- [ ] File is valid {LANG}
- [ ] `{lang}-lint --fix <file>` run, all violations fixed
```
