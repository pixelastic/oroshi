## Problem Statement

When Claude runs a Bash command containing a literal escape sequence like `\xa0` (e.g. a grep pattern), the `preToolUse-Bash` hook fails silently. The command is on the allowlist and Solkan correctly classifies it as **allow**, but the hook exits abnormally before producing an **auto-approve** response — causing Claude to fall back to asking the user for permission.

The root cause is in the RTK layer: `print --` in zsh interprets escape sequences even when the string comes from a variable. So `\xa0` (4 literal characters) is converted to byte 0xa0, which is invalid UTF-8. This byte reaches `jo` via the **auto-approve** helper, which asserts on invalid UTF-8 input and crashes.

## Solution

Add the `-r` (raw) flag to every `print --` call in the RTK rewrite function, making it `print -r --`. This suppresses escape-sequence interpretation, preserving the command string byte-for-byte through the RTK layer.

Apply the same fix to mock implementations of the RTK function in the integration test suite, so the mocks faithfully reproduce the real function's behavior.

Add a unit test that reproduces the failure before the fix and passes after: pass a command containing `\xa0` through the RTK **ignore** path (RTK has no rewrite for it) and assert the literal `\xa0` characters are preserved in the output.

## User Stories

1. As a developer, I want commands containing `\xa0` to be auto-approved without prompting, so that allowlisted grep patterns with non-breaking space escapes work transparently.
2. As a developer, I want the RTK layer to preserve the command string byte-for-byte, so that no escape sequence in any command is silently mangled before reaching `jo`.
3. As a developer, I want a regression test for this failure, so that future changes to the RTK rewrite function cannot re-introduce escape-sequence interpretation without a failing test.
4. As a developer, I want the test mocks of the RTK function to faithfully reproduce the real function's behavior, so that integration tests catch bugs that the real implementation would produce.

## Implementation Decisions

- **`print -r --` everywhere in the RTK rewrite function.** The `-r` flag is the correct fix: it tells zsh's `print` builtin to treat the string as raw data, suppressing all backslash interpretation (`\xa0`, `\n`, `\t`, etc.). This is strictly more correct than `print --` in all cases — no command should have its escape sequences interpreted by the RTK layer.

- **Three call sites in the RTK rewrite function.** The function has three output paths: (1) pass-through when the command is already in RTK form, (2) pass-through when RTK has no rewrite (**ignore**), (3) prepend `rtk` when RTK has a rewrite (**rewrite**). All three use `print --` and all three must be updated.

- **Mocks in the integration test suite also updated.** The mocks inline the same `print --` pattern. Leaving them unfixed would mean integration tests cannot detect the same class of bug.

- **No changes to `autoApprove` or `jo`.** The fix is applied at the source — the RTK layer — not at the consumer. `jo`'s UTF-8 assertion is correct behavior; the RTK layer should never produce invalid UTF-8.

- **No changes to the Solkan layer or the main hook orchestrator.** Neither uses `print` to output the command; this issue is isolated to the RTK rewrite function.

## Testing Decisions

Good tests for the RTK rewrite function test external behavior only: given a command string as input, what string appears on stdout? They do not assert on which internal branch was taken or whether `rtk-can-rewrite` was called.

**Module under test:** the RTK rewrite function (unit test).

**New test:** Pass a command containing a literal `\xa0` escape sequence through the RTK **ignore** path (mock `rtk-can-rewrite` to exit 1). Assert the output equals the input unchanged — specifically that `\xa0` appears as 4 literal characters, not as byte 0xa0. This test fails before the fix and passes after.

**Prior art:** The existing RTK unit tests in the same bats file follow the same pattern — mock `rtk-can-rewrite`, invoke the function, assert on `$output`. The new test is a straightforward addition to that suite.

## Out of Scope

- Integration test coverage of the `\xa0` scenario through the full hook pipeline (Solkan + RTK + `autoApprove`).
- Fixing any other hook files that might use `print --` without `-r` (none were found).
- Protecting against other classes of invalid UTF-8 beyond escape sequences interpreted by `print`.
- Changes to `rtk-can-rewrite` or `rtk rewrite`.
