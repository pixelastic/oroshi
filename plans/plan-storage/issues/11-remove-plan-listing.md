## TLDR

Remove `plan-list-raw`, `fzf-plans`, `complete-plans`, and the Ctrl-O ralph dispatch.

## What to build

Delete these functions and their tests:
- `tools/term/zsh/config/functions/autoload/plan/plan-list-raw` + `__tests__/plan-list-raw.bats`
- `tools/term/zsh/config/functions/autoload/fzf/fzf-plans` + `__tests__/fzf-plans.bats`
- `tools/term/zsh/config/functions/autoload/completion/complete-plans`

Update `tools/term/zsh/config/keybindings/ctrl-o.zsh`:
- Remove the `ralph` and `raplh` dispatch entries that route to `fzf-plans`.

Remove `plan-list-raw` from `tools/ai/claude/config/hooks/allow-list.json` if present.

Remove plan-related `.gitignore` entries that reference `plans/*/` patterns (these are no longer needed since plans are external).

## Scaffolding Tests

- `plan-list-raw`, `fzf-plans`, `complete-plans` functions no longer exist
- No reference to `fzf-plans` in keybindings

## Acceptance criteria

- [ ] `plan-list-raw` function and tests deleted
- [ ] `fzf-plans` function and tests deleted
- [ ] `complete-plans` function deleted
- [ ] Ctrl-O no longer dispatches `ralph` to `fzf-plans`
- [ ] allow-list.json updated
- [ ] Plan-related `.gitignore` entries removed
