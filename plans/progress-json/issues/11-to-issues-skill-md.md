## TLDR

Update the to-issues SKILL.md to reference the new file structure and templates.

## What to build

Update `tools/ai/claude/config/skills/to-issues/SKILL.md`:

**Step 4** — change what gets created:
- `state.json` (link to `references/state-json.md`) instead of `issues.json`
- `GUIDANCE.md` (link to `references/guidance-md.md`) instead of `progress.md`
- Issue files in `issues/` subdirectory as `XX-slug.md` (link to `references/issue-XX-slug.md`)
- Remove all references to `progress.md` and `issues.json`

**Checklist** — update to reflect new file names:
- `state.json` written with all issues having `done: false`
- `GUIDANCE.md` written with Guidance and empty Discoveries sections
- Issue files written in `issues/` subdirectory

## Acceptance criteria

- [ ] SKILL.md Step 4 references state.json, GUIDANCE.md, and issues/ subdirectory
- [ ] All links point to the updated reference files
- [ ] No mention of `progress.md`, `issues.json`, or `prd.json` anywhere
- [ ] Checklist updated to match new file names