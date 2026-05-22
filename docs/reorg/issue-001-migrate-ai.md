## PRD

[reorg/PRD.md](./PRD.md)

## What to build

Migrate the `ai` domain from the three-tree structure into `tools/ai/`. Each tool gets a folder containing its `install`, `deploy`, and/or `config/` as siblings. Deploy scripts reference their config via `$(dirname "$0")/config`. Install scripts call their deploy at the end. Cross-tool references inside moved files are updated to `$OROSHI_ROOT/tools/...`.

Tools in scope: `claude` (install currently named `claudecode`), `claude-blog`, `humanizer`, `rtk`, `skills` (from install); `claude` (from deploy); `claude` (from config).

Note: the canonical name is `claude`, not `claudecode`.

## Acceptance criteria

- [ ] `tools/ai/` directory created
- [ ] `scripts/install/ai/claudecode` moved to `tools/ai/claude/install`
- [ ] `scripts/install/ai/claude-blog` moved to `tools/ai/claude-blog/install`
- [ ] `scripts/install/ai/humanizer` moved to `tools/ai/humanizer/install`
- [ ] `scripts/install/ai/rtk` moved to `tools/ai/rtk/install`
- [ ] `scripts/install/ai/skills` moved to `tools/ai/skills/install`
- [ ] `scripts/deploy/ai/claude` moved to `tools/ai/claude/deploy`
- [ ] `config/ai/claude/` moved to `tools/ai/claude/config/`
- [ ] `tools/ai/claude/deploy` references config via `$(dirname "$0")/config` (not hardcoded path)
- [ ] `tools/ai/claude/install` calls `$(dirname "$0")/deploy` at the end
- [ ] Cross-tool references inside moved files updated to `$OROSHI_ROOT/tools/ai/claude/config/...`
- [ ] `scripts/install/ai/` and `scripts/deploy/ai/` and `config/ai/` are empty and removed

## Blocked by

None — can start immediately
