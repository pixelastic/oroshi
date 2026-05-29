## TLDR

Shrink mode badge from full word to single letter (` NORMAL ` → ` N `).

## What to build

In `getMode()`, replace the full-word mode strings with single-letter equivalents, keeping the surrounding spaces so the badge retains its pill shape. All five modes are affected: normal, insert, visual, search, command.

## Acceptance criteria

- [ ] Normal mode displays ` N ` in the statusline
- [ ] Insert mode displays ` I `
- [ ] Visual mode displays ` V `
- [ ] Search mode displays ` S `
- [ ] Command mode displays ` C `
- [ ] Badge colors and highlight groups are unchanged
