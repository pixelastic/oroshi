# Skill — Programming Languages

Template for the `{lang}-writer` skill when the language is a
[programming language](README.md#language-categories).

## Directory structure

```
{lang}-writer/
  SKILL.md            # Main skill file — defines the TDD-driven workflow
  references/         # Supplementary docs referenced by SKILL.md
    style.md          # Style rules not enforced by the linter
    testing.md        # Test framework conventions and patterns
    ...               # Additional files as needed by the language
```

The `references/` directory contains material too detailed for the main skill
file. SKILL.md references these files by relative path so the agent loads them
on demand rather than all at once.

Two files are expected:

- **`style.md`** — style rules too fuzzy for deterministic linter enforcement
- **`testing.md`** — test framework conventions, patterns, and runner usage

Additional files are free-form and vary by language (e.g. preferred libraries,
argument parsing conventions, language-specific idioms).

## Workflow

The skill enforces a TDD-driven sequence:

1. **Place** the file in the correct location following project structure
   conventions and naming rules
2. **Test first** — write a failing test before any production code
3. **Make it pass** with minimal code
4. **Refactor** applying the style conventions defined in [`style.md`](#directory-structure)
5. **Lint** with [`{lang}-lint --fix`](scripts.md#lang-lint)

## What SKILL.md defines

- The language's test framework and test file naming convention
  (e.g. `__tests__/module.js`, `__tests__/test_module.py`)
- How to run tests via [`{lang}-test`](scripts.md#lang-test)
- How to lint via [`{lang}-lint`](scripts.md#lang-lint)
- Project structure conventions
- Style rules the linter cannot enforce
- Preferred libraries and when to use them

**Dependencies:**

- Invokes [`{lang}-lint --fix`](scripts.md#lang-lint) for linting
- Invokes [`{lang}-test`](scripts.md#lang-test) for running tests
- Used alongside [RTK filtering](integration.md#rtk--test-output-filtering-for-agents) to keep test output concise
