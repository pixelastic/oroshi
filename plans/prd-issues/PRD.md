## Problem Statement

The skills `to-prd` and `to-issues` carry a `to-` prefix that no longer reflects how they are invoked (as `/prd` and `/issues`). The mismatch between directory names, frontmatter `name` keys, headings, and cross-references creates friction when reading or navigating skill files.

## Solution

Rename both skills from `to-prd` / `to-issues` to `prd` / `issues` within the worktree. Update every internal reference that mentions the old names so the codebase is fully consistent. Symlink management in `~/.claude/skills/` is handled separately by the user's install script.

## User Stories

1. As a developer invoking `/prd`, I want the skill directory to be named `prd/` so that the filesystem matches what I type.
2. As a developer invoking `/issues`, I want the skill directory to be named `issues/` so that the filesystem matches what I type.
3. As a developer reading `prd/SKILL.md`, I want the `name:` frontmatter key to be `prd` so that there is no confusion about the skill's identity.
4. As a developer reading `issues/SKILL.md`, I want the `name:` frontmatter key to be `issues` so that there is no confusion about the skill's identity.
5. As a developer reading `prd/SKILL.md`, I want the top-level heading to be `# PRD` so that the heading matches the skill name.
6. As a developer reading `issues/SKILL.md`, I want the top-level heading to be `# Issues` so that the heading matches the skill name.
7. As a developer reading `grill-me/SKILL.md`, I want the option to invoke `/prd` (not `/to-prd`) so that the cross-reference is correct after the rename.
8. As a developer reading `prd/SKILL.md`, I want the Step 4 prompt to reference `/issues` (not `/to-issues`) so that the handoff instruction is correct.
9. As a developer reading `scripts/bin/ai/prd/prd-end`, I want the header comment to reference `/prd` (not `/to-prd`) so that the comment accurately describes which skill calls the script.

## Implementation Decisions

- **Directory rename only within the worktree** — `skills/to-prd/` → `skills/prd/`, `skills/to-issues/` → `skills/issues/`. Symlinks in `~/.claude/skills/` are out of scope.
- **Minimal content changes** — only `name:` frontmatter key, top-level `#` heading, and cross-references (`/to-prd` → `/prd`, `/to-issues` → `/issues`) are modified. Descriptions, body content, and reference sub-files are untouched.
- **`prd-end` script untouched except its header comment** — the script logic, its directory (`scripts/bin/ai/prd/`), and its `allowlist.json` entry are all preserved as-is.
- **No new files** — this is a pure rename + text substitution with no additions.

## Testing Decisions

No tests are required. All changes are to content/config artifacts (Markdown skill files and a script comment). There is no executable logic to verify.

## Out of Scope

- Symlink management in `~/.claude/skills/` (handled by user's install script).
- Renaming `scripts/bin/ai/prd/` directory or the `prd-end` script itself.
- Updating skill `description:` fields.
- Any changes to reference sub-files (`references/prd-md.md`, `references/guidance-md.md`, etc.).
- Changes to `allowlist.json`.
