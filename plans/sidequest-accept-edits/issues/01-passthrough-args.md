## TLDR

Make kitty-helper-claude-start forward all arguments to claude transparently instead of handling only a single prompt arg.

## What to build

Replace the single-arg prompt handling in `scripts/bin/kitty/kitty-helper-claude-start` with `"$@"` passthrough. The helper becomes a thin wrapper: cd to git root, forward all args to `claude`, fall back to `zsh`.

Remove the `local prompt` / `local args` / conditional logic. The entire arg-forwarding section becomes `claude "$@" || true`.

## Behavioral Tests

Prior art: `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`

**No arguments**
- claude called with no args and zsh called after (existing — should still pass)

**Single prompt argument**
- claude called with the prompt string (existing — should still pass)

**Multiple arguments (flag + prompt)**
- claude called with all arguments forwarded in order (e.g. `--permission-mode acceptEdits @/path/to/file.md`)

**Non-zero claude exit**
- zsh still called when claude exits non-zero (existing — should still pass)

## Acceptance criteria

- [ ] `kitty-helper-claude-start` forwards `"$@"` to `claude`
- [ ] No flag parsing or arg filtering in the helper
- [ ] All existing tests still pass
- [ ] New multi-arg test passes
- [ ] `zsh-lint` passes
