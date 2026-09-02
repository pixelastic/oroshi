# Programming-Language Skill Template

Programming languages share a five-step TDD workflow:
place the file, write a failing test, make it pass, refactor, lint.

Each language fills in its own conventions, test framework, lint tool, and style
patterns.

## Required structure

```markdown
---
name: {lang}-writer
description: Use when writing or modifying {LANG} code. Apply when adding functions, fixing bugs, or implementing features.
---

# {LANG} Writer

## Overview

Write {LANG} code consistent with my conventions.

[Optional: preferred libraries or key references for the language.]

## Core Workflow

### Step 1 — Place the file

**Goal:** Correct structure around the file.

**Exit criterion:** Source file and tests are colocated correctly.

[File placement conventions: where source files go, where tests go, naming
patterns, directory structure example.]

### Step 2 — TDD: Write a failing test

**Goal:** Ensure the bug/feature has a failing test first.

**Exit criterion:** Test fails.

Write a failing test for the bug or missing feature you want to implement.

- Run `{test-cmd}` to run the tests
- See [Testing](./references/testing.md) for full examples and best practices

[Short test example in the language.]

### Step 3 — Make it work

**Goal:** Minimal code that makes the test pass.

**Exit criterion:** Test passes.

Write the simplest code that makes the test pass.
No patterns yet — just correct behavior.

- Run `{test-cmd}` to confirm.

### Step 4 — Refactor

**Goal:** Clean code that still passes.

**Exit criterion:** Tests still pass, patterns applied.

Apply patterns from [Style](./references/style.md):

| Pattern | Rule |
|---|---|
| Return early | No avoidable nesting |
| [language-specific] | [language-specific] |

[Optional: short refactored code example.]

- Run `{test-cmd}` to confirm tests still pass.

### Step 5 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `{lint-cmd}` on any modified `.{ext}` files
- Fix **every** violation, including pre-existing ones.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's only two levels of if/else, it's ok." | No it's not. Return early, always. |
| [language-specific] | [language-specific] |

## Checklist

- [ ] Return early — no avoidable nesting
- [ ] Tests pass after step 3
- [ ] Tests still pass after refactor
- [ ] `{lint-cmd}` run, all violations fixed
- [ ] [language-specific items]
```

## Required references

Each programming-language skill must include:

- `references/style.md` — language-specific style rules; must include all rules
  from `code-writer/references/style.md`
- `references/testing.md` — test framework conventions, examples, best practices
