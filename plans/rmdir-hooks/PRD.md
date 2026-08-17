## Problem Statement

When Claude Code runs `rmdir`, the Solkan rewrite (`rmdir` to `rmdir-for-claude`) silently fails. The command auto-approves and executes as plain `rmdir` — bypassing the worktree boundary check in `rmdir-for-claude`. This means directories outside the current repo can be deleted without prompt or safety net.

Root cause: the preToolUse-Bash hook reads Solkan's rewritten command from `.rewrittenCommand`, but Solkan outputs it under `.rewrite`. The field is always empty, so the original command passes through unchanged.

## Solution

Fix the field name mismatch in the hook so the Solkan rewrite is applied. Add integration tests that call real Solkan (no mock) for happy paths, so future Solkan output format changes break tests instead of silently breaking production.

## User Stories

1. As a developer using Claude Code, I want `rmdir` to be rewritten to `rmdir-for-claude`, so that directory deletion is confined to the current git worktree.
2. As a developer using Claude Code, I want `rm` to be rewritten to `rm-for-claude`, so that file deletion goes through the safety wrapper (same mechanism, same bug).
3. As a maintainer of the hook pipeline, I want integration tests that call real Solkan, so that a Solkan version bump that changes the output format is caught by CI before it reaches production.
4. As a maintainer of the hook pipeline, I want mocked tests for edge cases (compound commands, session state, RTK combos), so that the test suite stays fast while covering combinatorial paths.

## Implementation Decisions

- Fix goes in the consumer (preToolUse-Bash hook), not the producer (Solkan). Solkan's `.rewrite` key is intentional and consistent with its own naming.
- Only one production line changes: the `json-get` call that reads `.rewrittenCommand` becomes `.rewrite`.
- Existing mocked tests that hardcode `"rewrittenCommand"` in their fake Solkan output must update to `"rewrite"` to stay consistent.
- Three integration tests are added (real Solkan, no mock, RTK still mocked):
  - Allow happy path: `echo hello` — allowed, no rewrite
  - Rewrite happy path: `rmdir emptydir` — allowed, rewritten to `rmdir-for-claude emptydir`
  - Reject happy path: `wget evil.com` — rejected
- Integration tests live in the same `preToolUse-Bash.bats` file, grouped at the top.

## Testing Decisions

- Good tests verify external behavior (hook JSON output), not internal wiring.
- Integration tests call real Solkan with the real allowlist and rewrite list — they validate the full Solkan-to-hook contract.
- Mocked tests remain for edge cases where the combinatorial explosion (compound commands, session state, subagent injection) makes real Solkan calls unnecessary overhead.
- Prior art: existing tests in `preToolUse-Bash.bats` use `bats_mock`, `bats_run_zsh`, `expect_json`, and `expect_json_null`.

## Out of Scope

- Changes to Solkan itself (output format, CLI flags).
- Changes to `rmdir-for-claude` or `rm-for-claude` scripts.
- Changes to the allowlist or rewrite list.
- Changes to the RTK layer.
- Adding integration tests for non-rewrite paths (those are well-covered by mocks already).

## Further Notes

The same bug affects `rm` rewrites — `rm` to `rm-for-claude` is also silently dropped. The single-line fix resolves both.
