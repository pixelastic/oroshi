## TLDR

Wire up Solkan rewrite list + allowlist so `rm`/`rmdir` are rewritten and auto-approved through the hook pipeline.

## What to build

**New file: `tools/ai/claude/config/hooks/rewrite.json`**
```json
{
  "rm": "rm-for-claude",
  "rmdir": "rmdir-for-claude"
}
```

**Update: `tools/ai/claude/config/hooks/allowlist.json`**
- Add `rm-for-claude` and `rmdir-for-claude`

**Update: `tools/ai/claude/config/hooks/preToolUse-Bash-solkan.zsh`**
- Pass `--rewrite-list-file "${hookDir}/rewrite.json"` to the solkan call

**Update: `tools/ai/claude/config/hooks/preToolUse-Bash`**
- Extract `rewrittenCommand` from Solkan's JSON output (new field added by solkan-rewrite sidequest)
- Use `rewrittenCommand` (instead of raw `inputCommand`) as the command passed to RTK and all downstream output
- If `rewrittenCommand` is absent (no rewrite list provided), fall back to `inputCommand`

End-to-end flow after this issue:
1. Claude runs `rm foo.txt`
2. Hook sends to Solkan with rewrite list
3. Solkan rewrites to `rm-for-claude foo.txt`, validates against allowlist → allowed
4. Hook gets `rewrittenCommand: "rm-for-claude foo.txt"`, passes to RTK
5. Hook auto-approves
6. Shell executes `rm-for-claude foo.txt` → safety check → `/bin/rm` or error

## Behavioral Tests

**rm rewritten and allowed:**
- Input: `rm foo.txt` → Solkan returns rewrittenCommand `rm-for-claude foo.txt`, isAllowed true
- Hook output: permissionDecision `allow`, updatedInput.command `rm-for-claude foo.txt`

**rmdir rewritten and allowed:**
- Input: `rmdir emptydir` → rewritten to `rmdir-for-claude emptydir`, allowed
- Hook output: permissionDecision `allow`

**Compound command with rm:**
- Input: `ls && rm foo.txt` → rewritten to `ls && rm-for-claude foo.txt`, all allowed
- Hook output: permissionDecision `allow`, updatedInput.command `ls && rm-for-claude foo.txt`

**No rewrite list → fallback:**
- If Solkan returns no `rewrittenCommand`, hook uses original inputCommand

**Rewrite + RTK:**
- Solkan rewrites command, then RTK wraps it → both transformations applied

## Acceptance criteria

- [ ] `rewrite.json` exists with rm/rmdir mappings
- [ ] `rm-for-claude` and `rmdir-for-claude` in allowlist
- [ ] Solkan wrapper passes `--rewrite-list-file`
- [ ] Hook extracts and uses `rewrittenCommand`
- [ ] Fallback to `inputCommand` when no rewrite
- [ ] End-to-end: `rm foo` → auto-approved as `rm-for-claude foo`
- [ ] All existing hook tests still pass
- [ ] New hook integration tests pass
