## TLDR

One-time script to find and remove marks that duplicate project entries.

## What to build

Create a one-time cleanup script (can live in `scripts/bin/mark-cleanup-redundant` or be run ad-hoc):
1. Load `projects-load-definitions`
2. Iterate symlinks in `$MARKPATH`
3. For each, resolve the symlink target and compare against `PROJECTS[name:path]` (expanded)
4. If they match, list the mark as redundant
5. Print the list and ask for confirmation before deleting

This is HITL — the user reviews the list before deletion.

## Acceptance criteria

- [ ] Script identifies marks whose target matches a project path
- [ ] Lists redundant marks before deleting
- [ ] Asks for user confirmation
- [ ] Removes confirmed redundant symlinks
