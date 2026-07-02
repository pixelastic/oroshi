## Guidance

This plan fixes a silent hook failure caused by `print --` (without `-r`) interpreting `\xa0` escape sequences in the RTK rewrite function.

**Production file to fix:** `tools/ai/claude/config/hooks/preToolUse-Bash-rtk.zsh` in the oroshi dotfiles repo (`~/.oroshi`). This file is NOT in the solkan repo — edits must be made at that path directly.

**Test file to add to:** `~/.oroshi/tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-rtk.bats`

**Mock file to fix:** `~/.oroshi/tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`

**How to run the RTK unit tests:**
```zsh
bats ~/.oroshi/tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-rtk.bats
```

**How to run the full hook test suite:**
```zsh
bats ~/.oroshi/tools/ai/claude/config/hooks/__tests__/
```

**Prior art for bats tests:** See existing tests in `preToolUse-Bash-rtk.bats` — each test mocks `rtk-can-rewrite` via `bats_mock`, calls `bats_run_zsh` with the source prefix, and asserts `$status` and `$output`.

**Domain glossary:** `~/.oroshi/tools/ai/claude/config/hooks/GLOSSARY.md`

**Guard pattern:** `preToolUse-Bash-rtk.zsh` guards against re-definition (`whence preToolUse-Bash-rtk`) so bats tests can mock it by defining the function before sourcing.

## Discoveries

### Issue 01 — \xa0 regression test
- `review-diff dirty` sees an empty diff for `~/.oroshi/` changes — that repo is separate from this worktree. Spec review must be done manually for cross-repo changes.

### Issue 02 — mock print -r fix
- `print -- "\xa0"` in ZSH outputs raw byte 0xA0, not valid UTF-8. `jo` asserts UTF-8 validity and crashes — causing the hook to emit nothing, which jq then fails to parse. The failure mode is a crash, not a corrupted string.
- The `$OROSHI_ROOT` path convention does not apply to plan documentation files (GUIDANCE.md paths are human navigation aids, not sourced code).
