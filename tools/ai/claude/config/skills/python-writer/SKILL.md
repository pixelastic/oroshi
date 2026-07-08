---
name: python-writer
description: Use when writing or modifying Python code. Apply when adding functions, fixing bugs, or implementing features.
---

# Python Writer

## Overview

Write Python code consistent with my conventions.

## Core Workflow

### Step 1 — Do you really need Python?

**Goal:** Confirm Python is the right choice.

**Exit criterion:** Python is unavoidable for this task.

I prefer zsh (through `/zsh-writer`) for simple scripts or JavaScript (through `/js-writer`) for more complex modules.

Python is warranted only when a library or runtime has no ZSH/JS equivalent (e.g. kitty config)

If you can solve the problem in ZSH or JS — do that instead, and stop here.

### Step 2 — Place the file

**Goal:** Correct structure around the file.

**Exit criterion:** Source file, `__tests__/`, and `conftest.py` are colocated.

- Place the source file wherever it belongs for the project.
- Put tests in a `__tests__/` sibling directory, named `test_<module>.py`.
- Place `conftest.py` and `pyproject.toml` at the project root.

### Step 3 — TDD: Write a failing test

**Goal:** Ensure the bug/feature has a failing test first.

**Exit criterion:** Test fails.

Write a failing test for the bug or missing feature you want to implement.

- Test file: `test_<module>.py` in a `__tests__/` sibling directory
- Run `python-test <filepath>` to run the tests
- See [Testing](./references/testing.md) for full examples and best practices

```python
def test_returns_slugified_name():
    result = slugify("Hello World")
    assert result == "hello-world"
```

### Step 4 — Make it work

**Goal:** Minimal code that makes the test pass.

**Exit criterion:** Test passes.

Write the simplest code that makes the test green. Don't optimize yet.

Run `python-test <filepath>` to confirm.

### Step 5 — Refactor

**Goal:** Clean code that still passes.

**Exit criterion:** Tests still pass, patterns applied.

Apply patterns from [Style](./references/style.md):

| Pattern | Rule |
|---|---|
| Return early | No avoidable nesting |


Run `python-test <filepath>` to confirm tests still pass.

### Step 6 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `python-lint --fix <file>` on any modified `.py` files
- Fix **every** remaining violation

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Python is fine for this, it's just a small script." | Prefer ZSH or JS first. Python only when a library or runtime forces it. |
| "It's only two levels of if/else, it's ok." | No it's not. Return early, always. |

## Checklist

- [ ] Ensure python is the only choice
- [ ] Test file named `test_<module>.py` in `__tests__/` sibling directory
- [ ] Tests pass after step 4
- [ ] Return early — no avoidable nesting (step 5)
- [ ] Tests still pass after refactor
- [ ] `python-lint --fix <file>` run, all violations fixed
