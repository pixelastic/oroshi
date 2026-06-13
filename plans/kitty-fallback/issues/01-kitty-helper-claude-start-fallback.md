## TLDR

Fix the Claude starter script so both branches always fall back to zsh after Claude exits.

## What to build

Update the Claude starter script so that:

- Both the no-prompt and with-prompt branches absorb Claude's exit code (non-zero exits must not prevent the fallback).
- Both branches call plain `zsh` (without `exec`) as the final statement, replacing the previous `exec zsh` in the no-prompt branch and `exit 0` in the with-prompt branch.

Update the existing test file accordingly:

- No-prompt test: replace the manual fake-binary block (mkdir, printf, chmod, PATH prepend) with `bats_mock zsh`.
- With-prompt test: add `bats_mock zsh` so the test completes without invoking the real zsh binary. Add a third test case verifying that `zsh` is still called when `claude` exits non-zero.

## Behavioral Tests

**No-prompt branch**
- Claude is called without arguments and zsh is called after

**With-prompt branch**
- Claude is called with the prompt argument and zsh is called after
- zsh is still called when claude exits non-zero

## Acceptance criteria

- [ ] Closing a prompted Claude session leaves the Kitty tab open at a zsh prompt
- [ ] Closing a no-prompt Claude session still leaves the Kitty tab open at a zsh prompt
- [ ] A non-zero exit from Claude (either branch) still falls back to zsh
- [ ] No-prompt test uses `bats_mock zsh` instead of the manual fake-binary block
- [ ] With-prompt test mocks zsh and verifies fallback on non-zero claude exit
- [ ] All bats tests pass
- [ ] zsh-lint passes on the script
- [ ] bats-lint passes on the test file
