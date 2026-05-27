## PRD

[Merge main into reorg](PRD.md)

## What to do

Resolve conflicts for 5 hook files. They fall into two distinct sub-cases.

---

### Sub-case A — rename/delete conflicts (4 files)

```
tools/ai/claude/config/hooks/preToolUse
tools/ai/claude/config/hooks/preToolUse-Skill
tools/ai/claude/config/hooks/preToolUse-mcp
tools/ai/claude/config/hooks/sessionStart
```

**What happened:** main DELETED these files (the preToolUse dispatcher architecture was replaced by per-tool matchers in settings.json + the permissions block). Reorg MOVED them to `tools/` with path updates. Git will report these as `rename/delete` conflicts.

**Resolution:** Accept main's deletion — these files are no longer part of the architecture.

```bash
git rm tools/ai/claude/config/hooks/preToolUse
git rm tools/ai/claude/config/hooks/preToolUse-Skill
git rm tools/ai/claude/config/hooks/preToolUse-mcp
git rm tools/ai/claude/config/hooks/sessionStart
```

Why: main replaced the preToolUse dispatcher with individual matchers in settings.json (already resolved in issue-002). The permissions list in settings.json replaced preToolUse-Skill and preToolUse-mcp. sessionStart was outright removed.

---

### Sub-case B — content conflict (1 file)

```
tools/ai/claude/config/hooks/preToolUse-Bash
```

**What happened:** Both branches modified this file's content.
- **Reorg** (R089): updated internal paths from `config/ai/claude/hooks/` to `tools/ai/claude/config/hooks/`. Still used the OLD logic (single solkan check → acceptTool/letClaudeDecide).
- **Main** (R089): completely rewrote the script into an orchestrator that runs solkan and rtk sequentially, reads from stdin, and outputs structured JSON.

Main's rewrite is the correct target architecture (it's the result of the preToolUse PRD). The reorg change was just a path migration of the OLD version.

**Resolution:** Take main's rewritten version, update the one hardcoded path inside it:

```bash
git show main:config/ai/claude/hooks/preToolUse-Bash > tools/ai/claude/config/hooks/preToolUse-Bash
```

Then check if the script references any hardcoded `config/ai/claude/hooks/` path and replace with `tools/ai/claude/config/hooks/`. From the diff, main's version uses `${hookDir}` (computed from `${0:A:h}`) so no hardcoded paths — no edit needed.

---

## Acceptance criteria

- [ ] `preToolUse`, `preToolUse-Skill`, `preToolUse-mcp`, `sessionStart` are deleted from the working tree
- [ ] `preToolUse-Bash` has no `<<<<<<` markers
- [ ] `preToolUse-Bash` contains `PRETOOLUSE_SOLKAN_SCRIPT` and `PRETOOLUSE_RTK_SCRIPT` (main's orchestrator pattern)
- [ ] `preToolUse-Bash` does NOT contain `source ... hookLib.zsh` or `acceptTool` (old pattern)
- [ ] No hardcoded `config/ai/claude/hooks/` paths remain in any of these files

## Blocked by

issue-001
