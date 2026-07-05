## TLDR

Create the `debug-script` skill documenting when and how to write throw-away debug scripts.

## What to build

Create a new skill `debug-script` in `tools/ai/claude/config/skills/debug-script/SKILL.md`.

The skill must cover:

- **Trigger condition:** use this pattern when about to write a syntactically complex Bash command — multi-line, uses subshells, or involves non-trivial pipes. Simple allowlisted commands chained together (e.g. `git status && git diff`) do not qualify.
- **Target folder:** `/tmp/oroshi/claude/scripts/`
- **Naming:** descriptive name, no file extension
- **Shebang:** first line must be `#!/usr/bin/env zsh`
- **Permissions:** `chmod +x` before executing
- **Execution:** call the script directly by its full path — never via `zsh path/to/file`
- **Concrete example:** a zsh script block showing all of the above end-to-end
- **Node variant:** same pattern, just replace the shebang with `#!/usr/bin/env node`

## Behavioral Tests

Skipped — skill is a markdown file.

## Scaffolding Tests

Skipped — new file, no prior structure to transform.

## Acceptance criteria

- [ ] File exists at `tools/ai/claude/config/skills/debug-script/SKILL.md`
- [ ] Skill has correct YAML frontmatter (`name`, `description`)
- [ ] Trigger condition is documented (syntactic complexity, not call count)
- [ ] Target folder `/tmp/oroshi/claude/scripts/` is explicit
- [ ] No-extension naming convention is stated
- [ ] Shebang, chmod+x, and direct execution are all present
- [ ] A concrete zsh code example is included
- [ ] Node variant (shebang swap) is documented
- [ ] `skills list` shows `debug-script` after reload
