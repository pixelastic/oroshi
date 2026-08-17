## TLDR

Fix the Solkan rewrite field name mismatch in preToolUse-Bash and add integration tests that call real Solkan.

## What to build

The preToolUse-Bash hook reads `.rewrittenCommand` from Solkan's JSON output, but Solkan outputs the field as `.rewrite`. This silently drops rewrites (`rm` to `rm-for-claude`, `rmdir` to `rmdir-for-claude`), letting unsafe commands execute without the safety wrapper.

Three changes:

1. In `tools/ai/claude/config/hooks/preToolUse-Bash`, change the `json-get` call from `.rewrittenCommand` to `.rewrite`.

2. In `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`, update existing mocked tests that hardcode `"rewrittenCommand"` in their fake Solkan JSON to use `"rewrite"` instead.

3. In the same test file, add 3 integration tests at the top (grouped with a comment). These call real Solkan (no mock for `preToolUse-Bash-solkan`) with the real allowlist and rewrite list. RTK is still mocked (identity function). The three tests:
   - **Allow happy path:** `echo hello` — Solkan allows, no rewrite, hook auto-approves with original command.
   - **Rewrite happy path:** `rmdir emptydir` — Solkan rewrites to `rmdir-for-claude emptydir`, hook auto-approves with rewritten command.
   - **Reject happy path:** `wget evil.com` — Solkan rejects, hook asks with reason showing `wget`.

## Behavioral Tests

**Integration — allow happy path:**
- real Solkan allows `echo hello`
- hook outputs `permissionDecision: "allow"` and `updatedInput.command: "echo hello"`

**Integration — rewrite happy path:**
- real Solkan rewrites `rmdir emptydir` to `rmdir-for-claude emptydir`
- hook outputs `permissionDecision: "allow"` and `updatedInput.command: "rmdir-for-claude emptydir"`

**Integration — reject happy path:**
- real Solkan rejects `wget evil.com`
- hook outputs `permissionDecision: "ask"` and `permissionDecisionReason` containing `wget`

## Acceptance criteria

- [ ] `json-get` in preToolUse-Bash reads `.rewrite` not `.rewrittenCommand`
- [ ] Existing mocked rewrite tests pass with `"rewrite"` key in mock output
- [ ] 3 integration tests pass calling real Solkan with real allowlist/rewrite files
- [ ] `bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats` passes all tests
