## Problem Statement

When Claude runs `git-file-test`, the full test output (passing + failing) is shown. RTK filtering is completely bypassed because `git-file-test` is a ZSH autoloaded function that the `rtk-command-rewrite` hook doesn't match, and its internal sub-commands (`bats`, `yarn run test`, `python-test`) never pass through the hook again.

## Solution

Add conditional RTK wrapping inside `git-file-test` itself. When running in a Claude context (`is-claude`), each sub-command is prefixed with `rtk bin-zsh` so RTK filters the output per test runner. Outside Claude, commands run unchanged.

## User Stories

1. As a Claude Code user, I want `git-file-test` output filtered to show only failing tests, so that my context window isn't wasted on passing tests.
2. As a developer running `git-file-test` outside Claude, I want the full unfiltered test output, so that I can see all results when debugging locally.
3. As a developer running `git-file-test` in Claude with mixed dirty files (ZSH + JS + Python), I want each test runner's output filtered independently by RTK, so that mixed output formats don't confuse the RTK parser.

## Implementation Decisions

- **Wrapping is internal to `git-file-test`, not at hook level.** The hook (`rtk-command-rewrite`) does NOT match `git-file-test`. This avoids RTK trying to parse mixed multi-runner output as a single stream.
- **Per-language RTK prefix.** Each sub-command (`bats`, `yarn run test`, `python-test`) is individually prefixed with `rtk bin-zsh` when in Claude context. This gives RTK a single test-runner format per invocation.
- **`rtk bin-zsh` for all runners.** Consistent prefix style. No special-casing `rtk bats` (native subcommand) — `rtk bin-zsh bats` is used instead, matching the pattern `rtk-command-rewrite` already produces for the hook path.
- **Array prefix variable.** A single `is-claude` check at the top sets `local rtkPrefix=()` or `(rtk bin-zsh)`. Sub-commands use `"${rtkPrefix[@]}" <cmd>` — no repeated conditionals.
- **Claude detection via `is-claude`.** This function checks `CLAUDECODE=1`, which Claude Code sets natively.

## Testing Decisions

- **Mock `is-claude` in `setup()` defaulting to false (return 1).** All existing tests run as non-Claude. This prevents breakage when tests run inside Claude where `CLAUDECODE=1` is set.
- **New Claude-context tests mock `is-claude` returning 0 + mock `rtk`.** Verify that each sub-command receives the `rtk bin-zsh` prefix.
- **Prior art:** Existing `git-file-test.bats` tests mock `bats`, `yarn`, `python-test`, `bats-test-path` via `bats_mock`. Same pattern for the new tests.
- **Good test = test external behavior.** Verify the command that gets called (with or without prefix), not internal variable state.

## Out of Scope

- Modifying `rtk-command-rewrite` or `preToolUse-Bash` hook — wrapping is internal to `git-file-test`.
- Adding RTK support for other composite test runners beyond `git-file-test`.
- Changing how `rtk bin-zsh` itself filters output — that's RTK's concern.

## Further Notes

- History: `git-file-test` previously had `rtk bats` (commit b8481781f) but it was removed (fd3681f48) because it unconditionally wrapped, breaking non-Claude environments. This fix restores RTK wrapping conditionally.
