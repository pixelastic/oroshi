## TLDR

Delete old files, update compdef.zsh to split _jumps/_marks registrations.

## What to build

Delete:
- `scripts/bin/mark`
- `scripts/bin/unmark`
- `tools/term/zsh/config/aliases/jump.zsh`

Update `tools/term/zsh/config/completion/compdef.zsh`:
- Replace `compdef _jumps unmark j` with two lines:
  - `compdef _jumps mark-jump j`
  - `compdef _marks mark-delete`

Update `tools/term/zsh/config/aliases/index.zsh` if it sources `jump.zsh` — change to `mark.zsh`.

## Scaffolding Tests

**Old files removed:**
- `scripts/bin/mark` does not exist
- `scripts/bin/unmark` does not exist
- `tools/term/zsh/config/aliases/jump.zsh` does not exist

**compdef.zsh updated:**
- contains `compdef _jumps mark-jump j`
- contains `compdef _marks mark-delete`
- does not contain `compdef _jumps unmark j`

## Acceptance criteria

- [ ] `scripts/bin/mark` deleted
- [ ] `scripts/bin/unmark` deleted
- [ ] `jump.zsh` deleted
- [ ] `compdef.zsh` has separate `_jumps` and `_marks` registrations
- [ ] `index.zsh` updated if applicable
- [ ] No references to old `unmark` command in compdef
