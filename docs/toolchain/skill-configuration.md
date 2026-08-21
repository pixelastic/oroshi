# Skill — Configuration Languages

Template for the `{lang}-writer` skill when the language is a
[configuration language](README.md#language-categories).

## Directory structure

```
{lang}-writer/
  SKILL.md            # Main skill file — defines the lint-on-modify workflow
```

## Workflow

The skill enforces linting after every modification:

1. **Lint** with [`{lang}-lint --fix`](scripts.md#lang-lint)

## What SKILL.md defines

- How to lint via [`{lang}-lint`](scripts.md#lang-lint)

**Dependencies:**

- Invokes [`{lang}-lint --fix`](scripts.md#lang-lint) for linting
