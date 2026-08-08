## TLDR

Add input validation to git-remote-rename: check source exists, destination doesn't.

## What to build

1. **Guard: args required** — error if less than 2 args
2. **Guard: source remote exists** — error with colorized name if source doesn't exist
3. **Guard: destination remote doesn't exist** — error with colorized name if destination already exists
4. **Success feedback** — print confirmation message like git-remote-remove does

## Acceptance criteria

- [ ] `git-remote-rename` errors on missing args
- [ ] `git-remote-rename` errors if source remote doesn't exist
- [ ] `git-remote-rename` errors if destination remote already exists
- [ ] `git-remote-rename` prints confirmation on success
- [ ] `zsh-lint` passes on all touched files
