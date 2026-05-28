## TLDR

Update the issue template reference to match the new format: TLDR, no PRD section, no Blocked by, 2-digit ids, `issues/` subdirectory.

## What to build

Update `references/issue-XX-slug.md` in the to-issues skill directory. Three changes:

1. **TLDR at the top**: the file starts with a one-line plain-text summary before any heading. This gives humans and agents an instant overview without reading the full spec.

2. **Remove `## PRD` section**: the PRD is always at `../PRD.md` relative to the `issues/` subdirectory — no need to reference it explicitly.

3. **2-digit ids, no `issue-` prefix**: files live in `issues/XX-slug.md`, not `issue-XX-slug.md` at the plan root.

Remove the `## Blocked by` section from the template — dependencies are tracked in state.json, not in the issue file.

Remove the duplicate `references/issue-XXX-slug.md`.

Also remove `references/prd-json.md` (old issues.json reference that was a duplicate of issues-json.md).

## Acceptance criteria

- [ ] Template starts with a one-line TLDR before `## What to build`
- [ ] No `## PRD` section in the template
- [ ] Template filename convention documented as `XX-slug.md` (2-digit, no prefix)
- [ ] No `## Blocked by` section in the template
- [ ] `references/issue-XXX-slug.md` removed
- [ ] `references/prd-json.md` removed

## Blocked by

None — can start immediately
