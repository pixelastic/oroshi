## TLDR

Add a failing bats unit test asserting that `\xa0` in a command is preserved byte-for-byte through the RTK **ignore** path.

## What to build

Add one test to the RTK rewrite function's bats unit test suite. The test mocks `rtk-can-rewrite` to exit 1 (RTK **ignore**s the command) and passes a command containing the literal 4-character sequence `\xa0`. It asserts the output equals the input unchanged — specifically that `\xa0` is not converted to byte 0xa0.

This test must be written first and must fail before the production fix in issue 02 is applied.

## Behavioral Tests

**`\xa0` preserved through RTK ignore path**
- Given a command containing `\xa0` as 4 literal characters
- When `rtk-can-rewrite` exits 1 (ignore)
- Then the output equals the input unchanged, with `\xa0` still present as 4 literal characters

## Acceptance criteria

- [ ] New test exists in the RTK rewrite function's bats unit test suite
- [ ] Test fails on the unmodified production code (red)
- [ ] All pre-existing RTK unit tests still pass
