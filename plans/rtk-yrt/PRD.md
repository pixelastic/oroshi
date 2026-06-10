## Problem Statement

When Claude Code runs `yarn run test` (which invokes Vitest via aberlaas), the full verbose output — passing test lines, timing info, headers — is sent to the LLM context unchanged. This wastes tokens on noise. The RTK hook that already reduces BATS output does not activate for `yarn run test` because `rtk-can-rewrite` only detects TOML filters by matching the first word of the command against section names, and no `[filters.yarn]` entry exists. Additionally, even if the TOML entry were added, the first-word detection would produce false positives for other `yarn` commands (`yarn install`, `yarn add`, etc.).

## Solution

Add `yarn run test` to the RTK pipeline by:

1. Adding a `[filters.yarn]` TOML filter that strips passing test lines, headers, and timing from Vitest output, leaving only failure details and showing "All tests passed." when all tests pass.
2. Fixing `rtk-can-rewrite` to replace the TOML first-word lookup with a hardcoded list of known patterns, eliminating false positives for non-test yarn commands while correctly matching `bats` and `yarn run test`.

## User Stories

1. As Claude Code, I want `yarn run test` output reduced to failures only, so that I consume fewer tokens when running JS tests.
2. As Claude Code, I want to see "All tests passed." when all tests pass, so that I get a clear signal without verbose output.
3. As Claude Code, I want to see the full failure details (AssertionError, diff, stack trace) when tests fail, so that I can diagnose the problem.
4. As Claude Code, I want `yarn run test path/to/file.js` to be filtered the same way as a bare `yarn run test`, so that targeted test runs are also token-efficient.
5. As Claude Code, I want `yarn run test path/to/file.js -- --reporter verbose` (with extra flags) to be filtered, so that all invocation forms are covered.
6. As Claude Code, I want `yarn install` and other non-test yarn commands to pass through RTK unfiltered, so that their output is not incorrectly suppressed.
7. As a developer, I want `rtk-can-rewrite` to correctly return exit 0 for `yarn run test` and exit 1 for `yarn install`, so that the hook makes the right decision.
8. As a developer, I want `rtk-can-rewrite` to continue to return exit 0 for `bats` commands, so that existing BATS filtering is not broken.
9. As a developer, I want `rtk-can-rewrite` to produce no stdout in any case, so that the hook can rely solely on its exit code.

## Implementation Decisions

- **`rtk-can-rewrite` detection strategy**: Replace the TOML first-word section lookup with a hardcoded array of regex patterns. Each pattern covers one family of commands that has a corresponding TOML filter or built-in RTK rewrite. The `rtk rewrite` built-in check (step 1) is kept as-is; the TOML lookup (step 2) is replaced by iterating over the hardcoded patterns and testing with `=~`.

- **Hardcoded patterns**: Two patterns are registered at launch:
  - `^bats\b` — covers all bats invocations (previously detected via `[filters.bats]` section name)
  - `^yarn run test(\b| |$)` — covers `yarn run test` with any trailing arguments; does NOT match `yarn install`, `yarn add`, etc.

- **TOML filter for yarn**: A new `[filters.yarn]` entry is added with `match_command = "^yarn run test\b"`. RTK uses this at execution time to decide whether to apply the filter when invoked as `rtk yarn ...`. This means non-test yarn commands wrapped by RTK (e.g. due to future false positives) will pass through unchanged.

- **Vitest filter rules** (from prototype against real aberlaas/Vitest output):
  - `strip_ansi = true`
  - Strip lines matching: `✓` (passing tests), `RUN` header, all-passing `Test Files`/`Tests` summary lines (pattern: `^\s*(Test Files|Tests)\s+\d+ passed`), `Start at`, `Duration`, `✘ Tests are failing`
  - `on_empty = "All tests passed."`
  - Lines kept on failure: `❯` file/describe headers, `×` failing test lines, the `Failed Tests` separator, `FAIL` block with AssertionError and diff, source context, mixed summary lines (e.g. `1 failed | 1 passed`).

- **Vitest demo file cleanup**: The `tools/ai/rtk/__tests__/vitest-demo/` directory created during prototyping must be deleted before merging.

## Testing Decisions

Good tests check external behavior (exit code, stdout, filtered output) — not implementation details like which internal branch was taken.

**`rtk-can-rewrite` tests** — rewrite entirely:
- Remove the TOML filter file setup from `setup()`; the function no longer reads TOML at runtime.
- Test cases: `git status` (built-in, exit 0), `bats foo.bats` (exit 0), `yarn run test` (exit 0), `yarn run test path/to/file.js` (exit 0), `yarn run test path/to/file.js -- --reporter verbose` (exit 0), `yarn install` (exit 1), `echo hello` (exit 1).
- Verify no stdout for any case.
- Prior art: existing `rtk-can-rewrite.bats`.

**`rtk.bats` tests** — add yarn filter cases alongside existing bats cases:
- All-passing: `rtk yarn run test <passing-file>` exits 0 and output equals "All tests passed."
- Failing: `rtk yarn run test <failing-file>` exits 1, output contains failure details, output does not contain `✓` passing lines.
- Prior art: existing `rtk bats` tests in `rtk.bats`.

## Out of Scope

- Supporting `yarn test` (shorthand without `run`) — only `yarn run test` is in scope.
- Supporting `pnpm run test`, `npm test`, or other package managers.
- Making `rtk rewrite` aware of TOML filters (would require changes to the RTK binary).
- Fixing the `rtk test` built-in's last-5-lines truncation for Vitest output.
- Any changes to the preToolUse-Bash hook itself or the allowlist.

## Further Notes

- RTK honors `match_command` at execution time: when `rtk yarn install` runs and no `match_command` pattern matches, RTK executes the command as a passthrough. False positives in `rtk-can-rewrite` are therefore harmless but undesirable for clarity.
- `rtk rewrite` only knows built-in rewrites (git, gh, pnpm, etc.) — it does not consult TOML filters. This is why `rtk-can-rewrite` needs its own detection logic for TOML-backed commands.
