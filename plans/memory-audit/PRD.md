## Problem Statement

Claude Code's auto-memory system stores feedback and project context in `~/.claude/projects/*/memory/` — outside the repo, never committed, invisible to code review. Over time, memories go stale (9/10 project memories describe finished work), duplicate skill/CLAUDE.md instructions (12/30 feedback memories are redundant), and add non-determinism to conversations. Important conventions should live in version-controlled CLAUDE.md files, not in opaque side-storage.

## Solution

Disable auto-memory globally, delete all memory files across all 165 projects, and migrate the 4 genuinely useful feedback memories into the appropriate CLAUDE.md files where they become version-controlled, reviewable, and deterministic.

## User Stories

1. As a developer, I want Claude's behavior to be fully determined by committed CLAUDE.md and skill files, so that I can review and version-control all instructions
2. As a developer, I want stale project context removed, so that Claude doesn't act on outdated information about finished work
3. As a developer, I want redundant feedback memories eliminated, so that instructions have a single source of truth (skills or CLAUDE.md)
4. As a developer, I want other projects' memories reviewed before deletion, so that any useful convention is migrated to that project's CLAUDE.md
5. As a developer, I want auto-memory disabled globally, so that new memory files don't silently accumulate again

## Implementation Decisions

- **Global disable**: `autoMemoryEnabled: false` in `~/.claude/settings.json`, not per-project
- **Migration targets**: 3 feedbacks → oroshi CLAUDE.md, 1 feedback → ~/CLAUDE.md
- **Format**: `- DO:` / `- DO NOT:` items, matching existing CLAUDE.md style
- **Other projects**: review 25 memories across 9 projects before deleting; migrate to project CLAUDE.md if warranted
- **Full cleanup**: delete `~/.claude/projects/*/memory/` directories entirely, no empty skeletons
- **Oroshi CLAUDE.md feedbacks**: no_write_utf8_files, skill_edits_worktree_only, bin_symlink_pattern
- **Global CLAUDE.md feedback**: use_scripts (multi-step commands → /tmp/oroshi/claude/scripts/)

## Testing Decisions

No automated tests — this is a config/cleanup task. Verification is:
- Grep CLAUDE.md files for migrated content
- Confirm no memory/ directories remain
- Confirm settings.json contains the disable flag

## Out of Scope

- Creating a lua-writer skill (would have absorbed NeoVim feedback memories)
- Rewriting or restructuring existing CLAUDE.md sections
- Modifying skill files

## Further Notes

The principle driving this change: if a convention is important enough to remember, it should be committed with the project in CLAUDE.md, not stored in opaque side-storage.
