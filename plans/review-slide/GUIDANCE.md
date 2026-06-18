## Guidance

- Skills live at `tools/ai/claude/config/skills/<name>/SKILL.md` with `references/` subdirectory
- The `~/.claude/skills/` directory contains symlinks — always edit files under the worktree path, never via the symlink
- Prior art: `tools/ai/claude/config/skills/review/` — same orchestrator + parallel sub-agents pattern
- The existing `review` skill spawns 2 agents; this skill spawns 4
- Sub-agent briefs must be self-contained — each agent reads its own reference file, not the SKILL.md
- Each sub-agent reads the screenshot via the Read tool (Claude is multimodal)
- Output format per finding: principle violated, what's wrong (cite slide area), severity (blocking / improvement / nitpick)
- Test image available at: `https://algolia-grid.enterprise.slack.com/files/U06B923BL/F0BBMLQM92M/screenshot_2026-06-18_at_17.14.44.png` (download manually to a local path before testing)

## Discoveries
