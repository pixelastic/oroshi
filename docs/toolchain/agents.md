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
# Claude Code skill for writing code in a specific language.
# Location: tools/ai/claude/config/skills/{lang}-writer/
# Loaded automatically when the agent writes or modifies files
# in the corresponding language.
```

### Directory structure

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

Two files are expected in every skill:

- **`style.md`** — style rules too fuzzy for deterministic linter enforcement
- **`testing.md`** — test framework conventions, patterns, and runner usage

Additional files are free-form and vary by language (e.g. preferred libraries,
argument parsing conventions, language-specific idioms).

### Canonical workflow

The skill enforces a TDD-driven sequence:

1. **Place** the file in the correct location following project structure
   conventions and naming rules
2. **Test first** — write a failing test before any production code
3. **Make it pass** with minimal code
4. **Refactor** applying the style conventions defined in [`style.md`](#directory-structure)
5. **Lint** with [`{lang}-lint --fix`](scripts.md#lang-lint)

### What SKILL.md defines

- The language's test framework and test file naming convention
  (e.g. `__tests__/module.test.js`, `__tests__/test_module.py`)
- How to run tests via [`{lang}-test`](scripts.md#lang-test)
- How to lint via [`{lang}-lint`](scripts.md#lang-lint)
- Project structure conventions
- Style rules the linter cannot enforce
- Preferred libraries and when to use them

**Dependencies:**

- Invokes [`{lang}-lint --fix`](scripts.md#lang-lint) for linting
- Invokes [`{lang}-test`](scripts.md#lang-test) for running tests
- Used alongside [RTK filtering](integration.md#rtk--test-output-filtering-for-agents) to keep test output concise

---

## CLAUDE.md entries

```
# Project-level command entries for AI agents.
# Location: CLAUDE.md (repository root)
# Ensures Claude knows how to test and lint files in each language.
```

### Entry format

Each language registers two entries in the `## Commands` section:

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

1. Create `tools/ai/claude/config/skills/{lang}-writer/SKILL.md` with the
   canonical workflow adapted to the language's tooling
2. Add reference documents under `references/` for style, testing, and library
   conventions
3. Run `tools/ai/claude/deploy` to symlink the new skill into `~/.claude/skills/`
4. Add `Testing` and `Linting` entries to the `## Commands` section of the root
   CLAUDE.md
5. Reference the skill in `tools/ai/claude/config/CLAUDE.md`'s "use dedicated
   skill per language" line
