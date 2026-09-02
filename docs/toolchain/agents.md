# AI Integration

AI agents (Claude Code and similar) use the toolchain through two mechanisms:
skill files that encode language-specific workflows, and project-level CLAUDE.md
entries that expose test and lint commands to any agent. Together they ensure
agents follow the same TDD workflow and toolchain conventions as human
developers.

See [scripts.md](scripts.md) for the per-language ZSH functions these
mechanisms invoke.

---

## `{lang}-writer` skill

```
# Claude Code skill for writing or modifying files in a specific language.
# Location: tools/ai/claude/config/skills/{lang}-writer/
# Loaded automatically when the agent writes or modifies files
# in the corresponding language.
```

Each [language category](README.md#language-categories) has its own template:

- [skill-configuration.md](skill-configuration.md) — lint-on-modify workflow
- [skill-programming.md](skill-programming.md) — TDD-driven workflow with
  style and testing references

---

## CLAUDE.md entries

```
# Project-level command entries for AI agents.
# Location: CLAUDE.md (repository root)
# Ensures Claude knows how to test and lint files in each language.
```

### Entry format

Each language registers a `Linting` entry in the `## Commands` section.
[Programming languages](README.md#language-categories) also register a
`Testing` entry.

```markdown
- **Testing {lang}:** Run `{lang}-test <filepath>`
- **Linting {lang}:** Run `{lang}-lint <filepath>`
```

These entries are the minimal contract: an agent that has never seen the
codebase before can read CLAUDE.md and immediately know how to validate its
changes.

**Dependencies:**

- References [`{lang}-test`](scripts.md#lang-test) and
  [`{lang}-lint`](scripts.md#lang-lint) by name
- Complements the [`{lang}-writer` skill](#lang-writer-skill) as a lightweight alternative

---

## Adding a language

See [Language categories](README.md#language-categories) for which steps apply.

All languages:

1. Create `tools/ai/claude/config/skills/{lang}-writer/SKILL.md` with the
   appropriate workflow for the language category
2. Add a `Linting` entry to the `## Commands` section of the root CLAUDE.md
3. (Optional) Add a `Testing` entry to the `## Commands` section of the root CLAUDE.md

Programming languages only:

5. Add reference documents under `references/` for style, testing, and library
   conventions
6. Add a `Testing` entry to the `## Commands` section of the root CLAUDE.md
