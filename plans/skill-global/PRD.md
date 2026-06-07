## Problem Statement

When an agent is asked to edit a skill file, it edits the globally-installed copy (`~/.claude/skills/<name>/SKILL.md`) instead of the copy tracked in the repository. This bypasses the current worktree entirely — the global install is a symlink to the main branch, so edits land on the wrong branch. The mistake recurs because agents have no clear instruction about where skill files are tracked, and rationally conclude "this is where the file lives."

## Solution

Update the `skill-writer` skill to be the authoritative source of truth for where skill files live and how to edit them. Additionally, update the `ralph` skill to include `skill-writer` in its list of language/type-specific skills to load, so agents implementing skill-related issues know to consult it.

## User Stories

1. As an agent using `skill-writer`, I want to know where skill files are tracked in the repository, so that I edit the correct copy and not the global install.
2. As an agent using `skill-writer`, I want to understand why `~/.claude/skills/` is the wrong place to edit, so that I don't rationalize my way back to the global path.
3. As an agent using `ralph` to implement a skill-related issue, I want to be prompted to load `skill-writer`, so that I inherit its file location rules automatically.
4. As a user, I want skill edits to always land in the current worktree, so that my changes are on the right branch and can be reviewed before merging.
5. As a user, I want the fix to be in a single authoritative skill (skill-writer) rather than scattered across global config, so that it remains maintainable.

## Implementation Decisions

- The `skill-writer` skill description is updated from "Use when creating or updating a discipline-enforcing skill" to "Use when creating or updating skills." — broader trigger, removes the qualifier that made it feel inapplicable to simple edits.
- A *File Locations* block is added to the `skill-writer` Overview section, stating: skills are tracked inside the repository under a dedicated skills config directory; the global install directory contains symlinks to the main branch, not the current worktree; agents must always edit the tracked copy inside the git root, never the global install.
- A row is added to the `skill-writer` Common Rationalizations table addressing the specific rationalization "this is where the file lives" → reality: that path is a symlink to the main branch, not the current worktree.
- The `ralph` skill Step 3 example list is updated to include `skill-writer` alongside `zsh-writer` and `js-writer`, without singling out a specific file type.

## Testing Decisions

No automated tests. Skill files are not unit-testable via bats or vitest. Validation is done manually via the `skill-writer test` TDD workflow when the user chooses to verify compliance.

## Out of Scope

- Adding a global CLAUDE.md rule about skill file locations.
- Modifying ralph to explicitly detect SKILL.md files and auto-load skill-writer.
- Updating other skills (review, issues, tdd) with similar file location guidance.
- Modifying the deploy/install scripts.

## Further Notes

The global install (`~/.claude/skills/`) is created by `tools/ai/claude/deploy`, which symlinks each skill directory from the repository to `~/.claude/skills/`. Because the symlink targets the main repo (not a worktree), editing via the global path always modifies the main branch regardless of which worktree is active.
