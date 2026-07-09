## Problem Statement

When an agent (Claude) runs Python tests via `python-test`, pytest outputs a verbose header (platform info, rootdir, configfile, collected items count) plus a line for every passing test — all of which is noise that wastes tokens. BATS and Vitest are already handled by RTK filters that strip passing output and show only failures.

## Solution

Register `python-test` as an RTK-rewritable command and define a pytest filter in RTK's filter config. When the agent calls `python-test`, RTK intercepts the call, runs pytest, and strips header lines and passing test lines from the output. If all tests pass, the entire output is replaced by a single "All tests passed." message. Only failures, failure details, and the short test summary reach the agent.

## User Stories

1. As an agent running `python-test ./foo.py`, I want to only see failing test output, so that I don't waste tokens processing passing test lines.
2. As an agent running `python-test ./foo.py` when all tests pass, I want to see exactly "All tests passed.", so that I get a clear, minimal confirmation.
3. As an agent running `python-test ./foo.py` when some tests fail, I want to see the FAILED lines, failure details, and short test summary, so that I can diagnose and fix the issue.
4. As a human developer running `python-test ./foo.py` directly in a terminal (without RTK), I want the full verbose pytest output unchanged, so that the tool's default behavior is not degraded.
5. As a developer, I want the RTK filter for pytest to be consistent with the existing BATS and Vitest filters, so that the system is predictable and maintainable.

## Implementation Decisions

- **Pattern registration**: The `rtk-can-rewrite` function is extended with a `^python-test\b` pattern, following the same approach as the existing `^bats\b` and `^yarn run test\b` patterns.

- **Filter config**: A new `[filters.pytest]` block is added to `filters.toml`. It matches `^python-test\b`, strips ANSI codes, and strips the following line patterns:
  - `^=+ test session starts` — opening header separator
  - `^platform ` — Python/pytest version line
  - `^rootdir:` — project root path
  - `^configfile:` — config file path
  - `^plugins:` — pytest plugins list
  - `^collected \d+` — collected items count
  - ` PASSED$` — individual passing test lines
  - `^=+ \d+ passed in` — all-passed footer line

- **on_empty behavior**: When all output is stripped (all tests passed), the filter emits `"All tests passed."` — consistent with the BATS and Vitest filters.

- **No changes to `python-test` script**: The script itself is not modified. RTK wraps it externally; the default human-facing behavior is preserved.

- **No `pytest` direct-call pattern**: Only `python-test` is registered. The agent is expected to always use the wrapper.

## Testing Decisions

Good tests verify external behavior (what comes out), not implementation details (how the filter works internally). Tests should use real pytest invocations against real `.py` fixture files — not mocked output — so that the filter is validated end-to-end.

**Module 1 — Pattern recognition (`rtk-can-rewrite`)**
- Unit tests in `rtk-can-rewrite.bats`
- Prior art: existing tests for `bats` and `yarn run test` patterns in the same file
- Test cases:
  - `python-test foo.py` → exit 0
  - `python-test-something` → exit 1 (no false positive on prefix match)

**Module 2 — Filter config (`filters.toml`)**
- Integration tests in `rtk.bats`
- Prior art: existing `rtk bats` and `rtk yarn run test` integration tests in the same file
- Test cases:
  - `rtk python-test` on an all-passing `.py` file → output is exactly `"All tests passed."`
  - `rtk python-test` on a `.py` file with one passing and one failing test → output contains failure details, does not contain `PASSED`

## Out of Scope

- Indirect pytest calls: when `git-file-test` (or another wrapper) calls `python-test` as a subprocess, RTK does not intercept the inner call. This gap is deferred until Python support is added to `git-file-test`.
- Adding Python test discovery to `git-file-test` — out of scope for this plan.
- Filtering `pytest` called directly (without the `python-test` wrapper).
- Modifying the default `python-test` behavior for human users (no `--no-header -q` flags added).
