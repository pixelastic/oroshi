## TLDR

Update all external callers and config to reference `zsh-lint` instead of `zshlint`.

## What to build

Update every external reference to the renamed scripts:

- **Yarn script** (`scripts/yarn/lint-zsh`): update the call to `zshlint` → `zsh-lint`
- **Git helper** (`tools/term/zsh/config/functions/autoload/git/file/git-file-lint`): update the call to `zshlint` → `zsh-lint`
- **NeoVim integration**: update the linter key, command name, and diagnostic source from `zshlint` to `zsh-lint` in both `filetypes/zsh.lua` and `code-quality.lua`
- **Claude hooks allowlist**: update the three entries `zshlint`, `zshlint-shellcheck`, `zshlint-custom` to their `zsh-lint` equivalents
- **zsh-writer skill**: update the step that instructs running `zshlint <file>` → `zsh-lint <file>`
- **CLAUDE.md**: update the documented test command

No new tests — all these are config/doc changes per project convention.

## Acceptance criteria

- [ ] `lint-zsh` calls `zsh-lint`
- [ ] `git-file-lint` calls `zsh-lint`
- [ ] NeoVim linter registered and sourced as `zsh-lint`
- [ ] `allowlist.json` contains `zsh-lint`, `zsh-lint-shellcheck`, `zsh-lint-custom`
- [ ] `zsh-writer` SKILL.md references `zsh-lint`
- [ ] `CLAUDE.md` documents `zsh-lint` as the lint command
