## PRD

[Merge main into reorg](PRD.md)

## What to do

Resolve the conflict in `tools/ai/claude/config/settings.json`.

## What each branch changed

**main** made structural changes to the hook wiring:
- Added a `permissions.allow` block (BashOutput, Fetch, Glob, Grep, LS, Read, Search, Skill, SlashCommand, TodoWrite, WebFetch, WebSearch, mcp__context7, mcp__google-slides, mcp__make__scenarios_list)
- Removed the `SessionStart` hook (sessionStart script deleted in main)
- Removed the catch-all `PreToolUse /*` matcher (preToolUse dispatcher deleted in main)
- Removed the RTK hook entry (`preToolUse-Bash-rtk` / `rtk-rewrite.sh`)
- Added a `PreToolUse / Bash` matcher pointing to `preToolUse-Bash`
- All paths still used the old `config/ai/claude/hooks/` prefix

**reorg** kept the old hook structure but updated every path:
- `config/ai/claude/hooks/...` → `tools/ai/claude/config/hooks/...`
- Still had SessionStart, preToolUse dispatcher, RTK hook

## Resolution

The merge should produce a file that combines **main's architecture** with **reorg's paths**:

1. Keep main's `permissions.allow` block as-is
2. Keep main's `PreToolUse / Bash` matcher, update the path:
   `config/ai/claude/hooks/preToolUse-Bash` → `tools/ai/claude/config/hooks/preToolUse-Bash`
3. Drop SessionStart (main deleted that hook)
4. Drop the catch-all preToolUse dispatcher (main deleted it — replaced by the permissions block)
5. Drop the RTK hook entry (main removed it — RTK is now called inside preToolUse-Bash itself)
6. Keep whatever other hooks reorg had at `tools/` paths (Notification, Stop, etc.)

## Acceptance criteria

- [ ] File has no `<<<<<<` markers
- [ ] `permissions.allow` array present with all entries from main
- [ ] `PreToolUse / Bash` matcher points to `tools/ai/claude/config/hooks/preToolUse-Bash`
- [ ] No SessionStart hook entry
- [ ] No catch-all `matcher: "*"` PreToolUse entry
- [ ] No RTK hook entry
- [ ] All remaining paths use `tools/ai/claude/config/hooks/` prefix

## Blocked by

issue-001
