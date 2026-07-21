## Problem Statement

Universal coding rules (like "no abbreviated variable names") must be manually duplicated across each language writer skill. There is no single source of truth for these rules, and no reminder to sync them when creating new language skills. This leads to inconsistent enforcement — e.g. zsh-writer has the no-abbreviation rule but js-writer and python-writer don't.

## Solution

Establish `code-writer/references/style.md` as the canonical source of truth for universal coding conventions. Each language writer skill duplicates these rules in its own `references/style.md` with language-idiomatic examples. A new section in skill-writer reminds authors to sync universal rules when writing language skills.

## User Stories

1. As a developer using js-writer, I want the agent to avoid abbreviated variable names, so that my JS code stays consistent with my naming standards.
2. As a developer using python-writer, I want the agent to use full variable names in snake_case, so that my Python code follows the same no-abbreviation rule as other languages.
3. As a developer using code-writer for an unsupported language, I want the agent to know my universal conventions, so that even without a dedicated skill the output matches my standards.
4. As a skill author creating a new language writer, I want a reminder to check code-writer for universal rules, so that I don't forget to include them in the new skill.
5. As a developer, I want each language skill to be self-contained with all applicable rules, so that I don't depend on indirection or cross-skill loading.

## Implementation Decisions

- `code-writer/references/style.md` is created as the canonical list of universal rules. It contains "return early" and "no abbreviated variable names" with generic camelCase examples.
- `code-writer/SKILL.md` gets a new `## Style` section (after "When to Use") with a reference table linking to `references/style.md`.
- `js-writer/references/style.md` gets a new bullet for the no-abbreviation rule with camelCase examples (`absolutePath` not `absPath`).
- `python-writer/references/style.md` gets a new `## Naming` section with snake_case examples (`absolute_path` not `abs_path`).
- `zsh-writer` is unchanged — already has the rule in `references/variables.md`.
- `skill-writer/SKILL.md` gets a new section "Language writer skills" (between Step 2 and Step 3) reminding to include all universal rules from `code-writer/references/style.md`.
- No exceptions for common abbreviations — kept strict, exceptions added later if needed.
- Rules are duplicated (not inherited via indirection) to keep each skill self-contained.

## Testing Decisions

No tests. All changes are to skill prompt files (markdown). These are not executable code.

## Out of Scope

- Harmonizing the references directory structure across all writer skills (each skill organizes references differently).
- Adding other universal rules beyond "return early" and "no abbreviated variable names".
- Adding a linter or automated check for rule sync between skills.
- Modifying zsh-writer (already has the rule).

## Further Notes

The "return early" rule already exists in python-writer and zsh-writer but not in code-writer. Adding it to `code-writer/references/style.md` establishes the source of truth without removing it from language skills where it already lives.
