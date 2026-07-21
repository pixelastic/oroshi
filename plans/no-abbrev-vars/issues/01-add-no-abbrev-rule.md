## TLDR

Add the "no abbreviated variable names" rule to all writer skills, using code-writer as source of truth.

## What to build

Establish `code-writer/references/style.md` as the canonical list of universal coding conventions, then propagate to each language skill.

**Create:**
- `tools/ai/claude/config/skills/code-writer/references/style.md` — contains "return early" and "no abbreviated variable names" with generic camelCase examples

**Modify:**
- `tools/ai/claude/config/skills/code-writer/SKILL.md` — add `## Style` section (after "When to Use") with a reference table linking to `references/style.md`
- `tools/ai/claude/config/skills/js-writer/references/style.md` — add a bullet for no abbreviated variable names with camelCase examples (`absolutePath` not `absPath`, `configFile` not `confFile`)
- `tools/ai/claude/config/skills/python-writer/references/style.md` — add `## Naming` section with snake_case examples (`absolute_path` not `abs_path`, `config_file` not `conf_file`)
- `tools/ai/claude/config/skills/skill-writer/SKILL.md` — add "Language writer skills" section (between Step 2 and Step 3) reminding to include all universal rules from `code-writer/references/style.md`

**No changes:**
- `zsh-writer` — already has the rule in `references/variables.md`

## Acceptance criteria

- [ ] `code-writer/references/style.md` exists with return early + no abbreviations
- [ ] `code-writer/SKILL.md` has a Style section referencing it
- [ ] `js-writer/references/style.md` contains no-abbreviation rule with camelCase examples
- [ ] `python-writer/references/style.md` contains no-abbreviation rule with snake_case examples
- [ ] `skill-writer/SKILL.md` has a "Language writer skills" section pointing to `code-writer/references/style.md`
