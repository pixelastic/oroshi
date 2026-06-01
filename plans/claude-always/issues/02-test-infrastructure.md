## TLDR

Rename test mocks to match glossary vocabulary and add env var overrides for session/log paths.

## What to build

Three changes to align the test harness with the new glossary and prepare it for session state testing:

**1. Rename mocks** — mock names reflect what solkan returns, not the hook's decision:
- `mock-solkan-allow` — keep as-is (solkan allows, exit 0)
- `mock-solkan-ask` → `mock-solkan-reject-multi` (solkan rejects two binaries: wget, curl; exit 1)
- Add new `mock-solkan-reject-single` (solkan rejects one binary: wget; exit 1)

**2. `_run_hook` passes env var overrides** — the helper passes both `CLAUDE_HOOKS_LOG_DIR` and `CLAUDE_SESSIONS_DIR` pointing to `$BATS_TEST_TMPDIR` so tests are fully isolated from each other and from the live system.

**3. Hook: make `CLAUDE_HOOKS_LOG_DIR` overridable** — the hook currently hardcodes this path. Change it to use the env var with a default fallback.

After this issue, all existing tests must still pass with the renamed mocks.

## Acceptance criteria

- [ ] `mock-solkan-allow` exists and is unchanged
- [ ] `mock-solkan-reject-multi` replaces `mock-solkan-ask` (same behavior: rejects wget and curl)
- [ ] `mock-solkan-reject-single` exists and rejects only wget
- [ ] All references to `mock-solkan-ask` in existing tests updated to `mock-solkan-reject-multi`
- [ ] `_run_hook` passes `CLAUDE_HOOKS_LOG_DIR=$BATS_TEST_TMPDIR` to the hook
- [ ] `_run_hook` passes `CLAUDE_SESSIONS_DIR=$BATS_TEST_TMPDIR` to the hook
- [ ] Hook reads `CLAUDE_HOOKS_LOG_DIR` from env with `/tmp/oroshi/claude/hooks` as default
- [ ] All existing tests pass after the rename
