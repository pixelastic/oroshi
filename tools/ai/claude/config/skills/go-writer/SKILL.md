---
name: go-writer
description: Use when writing or modifying Go code. Apply when adding functions, fixing bugs, or implementing features.
---

# Go Writer

## Overview

Write Go code consistent with my conventions.

## Core Workflow

### Step 1 — Place the file

**Goal:** Correct structure around the file.

**Exit criterion:** Source file and tests are colocated in the right package.

- One package (directory) per domain — multiple `.go` files per package is normal
- Tests: `*_test.go` in the same package (standard Go convention)
- Build script at the project root, outputs binary to a `dist/` folder

### Step 2 — TDD: Write a failing test

**Goal:** Ensure the bug/feature has a failing test first.

**Exit criterion:** Test fails.

Write a failing test for the bug or missing feature you want to implement.

- Test file: `<module>_test.go` in the same package
- Run `go-test <filepath>` to run the tests
- See [Testing](./references/testing.md) for full examples and best practices

```go
func TestReturnsSlugifiedName(t *testing.T) {
    result := Slugify("Hello World")
    assert.Equal(t, "hello-world", result)
}
```

### Step 3 — Make it work

**Goal:** Minimal code that makes the test pass.

**Exit criterion:** Test passes.

Write the simplest code that makes the test pass.
No patterns yet — just correct behavior.

Run `go-test <filepath>` to confirm.

### Step 4 — Refactor

**Goal:** Clean code that still passes.

**Exit criterion:** Tests still pass, patterns applied.

Apply patterns from [Style](./references/style.md):

| Pattern | Rule |
|---|---|
| Return early | No avoidable nesting |
| Error handling | Early return on error, wrap with `%w` |
| Short functions | Extract when a function does more than one thing |

Run `go-test <filepath>` to confirm tests still pass.

### Step 5 — Lint

**Goal:** Automated style gate.

**Exit criterion:** Lint passes.

- Run `go-lint --fix <file>` on any modified `.go` files
- Fix **every** violation, including pre-existing ones.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's only two levels of if/else, it's ok." | No it's not. Return early, always. |
| "I'll add a bare panic for now." | No bare panics. Return an error. |
| "I don't need testify, stdlib is fine." | Use testify — `assert`/`require` are more readable than `if/t.Errorf`. |
| "I'll use `assert` for this error check." | Error/nil guards need `require` — test must stop, not limp along. |
| "I'll put everything in package main." | Split into packages by domain — but multiple files per package is normal. |

## Checklist

- [ ] One package per domain, multiple files per package OK
- [ ] Test file named `<module>_test.go` in same package
- [ ] Assertions use `assert`/`require` from testify — no `if/t.Errorf`
- [ ] `require` for guards (nil, error), `assert` for everything else
- [ ] Tests pass after step 3
- [ ] Return early — no avoidable nesting
- [ ] Errors wrapped with `fmt.Errorf("context: %w", err)`
- [ ] Tests still pass after refactor
- [ ] `go-lint --fix <file>` run, all violations fixed
