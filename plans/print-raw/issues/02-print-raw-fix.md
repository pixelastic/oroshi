## TLDR

Fix `print --` → `print -r --` in the RTK rewrite function and its test mocks so escape sequences are never interpreted.

## What to build

In the RTK rewrite function, change every `print --` to `print -r --`. There are three call sites: the pass-through when the command is already in RTK form, the pass-through when RTK **ignore**s the command, and the prepend when RTK **rewrite**s the command.

Apply the same change to every mock implementation of the RTK rewrite function in the integration test suite, so the mocks faithfully reproduce the real function's behavior.

## Behavioral Tests

**Issue 01's regression test turns green**
- The `\xa0` regression test added in issue 01 must pass after this fix

**All existing RTK unit tests still pass**
- No regressions in the RTK rewrite function's bats suite

**All existing integration tests still pass**
- No regressions in the full hook pipeline bats suite

## Acceptance criteria

- [ ] All three `print --` calls in the RTK rewrite function changed to `print -r --`
- [ ] All mock implementations of the RTK rewrite function in the integration test suite changed to `print -r --`
- [ ] Issue 01's `\xa0` regression test passes (green)
- [ ] Full bats test suite passes with no regressions
