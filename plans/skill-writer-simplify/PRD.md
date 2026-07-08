## Problem Statement

The `skill-writer` skill includes a 6-step TDD workflow (GRILL → RED → GREEN → PRESSURE → OPTIMIZE → DONE) that the user systematically skips. Steps 2-5 are dead weight: they reference a `skill-writer` binary that does not exist, introduce friction on every invocation, and add noise to a process that only needs shared understanding + correct authoring.

## Solution

Simplify `skill-writer` to a 3-step workflow: GRILL → WRITE → DONE. Remove all TDD steps and their cascading references (Overview description, Common Rationalizations, Checklist items). Delete the three reference files that only served the TDD steps. The result is a skill that enforces the essentials — understand the goal, write to the template, done.

## User Stories

1. As a skill author, I want to invoke `skill-writer` without being prompted through TDD steps I always skip, so that the workflow matches how I actually work.
2. As a skill author, I want GRILL to remain the first step, so that I reach shared understanding before writing anything.
3. As a skill author, I want a WRITE step that references `skill-template.md`, so that I know the expected format without having to remember it.
4. As a skill author, I want DONE to remain as an explicit closing step, so that the workflow has a clear end.
5. As a skill author, I want the Checklist to verify that the skill is in the right location and follows the template, so that structural mistakes are caught before committing.
6. As a skill author, I want Common Rationalizations to only warn about the symlink trap, so that the section remains focused on real risks.
7. As a skill author, I want the skill to not reference a `skill-writer` binary that does not exist, so that instructions are accurate and actionable.

## Implementation Decisions

- **3-step workflow**: GRILL (Step 1) → WRITE (Step 2) → DONE (Step 3). Steps 2-5 of the current skill are removed entirely.
- **WRITE step**: Minimal — instruct the agent to read `references/skill-template.md` and create or update the skill file at the canonical location.
- **DONE step**: No cleanup command (the `skill-writer` binary does not exist). Simple closing message: skill is written, commit your changes.
- **Overview**: Remove the TDD cycle description. Keep the canonical tracking path.
- **Common Rationalizations**: Retain only the symlink warning row. Remove the three TDD-specific rows.
- **Checklist**: Three items — user confirmed intent, skill at correct location, skill follows template. Remove the three TDD phase items.
- **Reference file deletion**: `pressure-types.md`, `persuasion-principles.md`, and `common-rationalization-table.md` are deleted. They are only referenced within the TDD steps being removed.
- **Reference files retained**: `skill-template.md`, `claude-frontmatter-docs.md`, `claude-full-docs.md` are untouched.

## Testing Decisions

No automated tests. Config and documentation changes are the artifact — the modified `SKILL.md` and deleted reference files are self-verifying by inspection. This follows the project convention for skill/config changes.

## Out of Scope

- Rewriting or improving the content of `skill-template.md`
- Any changes to `claude-frontmatter-docs.md` or `claude-full-docs.md`
- Building the `skill-writer` binary or any tooling around it
- Changes to any other skill

## Further Notes

The `skill-writer` binary (`skill-writer test`, `skill-writer ask`, `skill-writer clean`) does not exist anywhere in the codebase. All references to it are confined to the TDD steps being removed and will disappear with them.
