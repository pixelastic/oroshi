## PRD

[Merge main into reorg](PRD.md)

## What to do

Resolve the conflict in `tools/vim/nvim/config/config/filetypes/colors.lua`.

## What each branch changed

**Main** added two new `onWrite` watchers at the end of `M.onInit`:
```lua
-- Projects
F.onWrite("*config/term/zsh/theming/src/projects.json", executeCommand("projects-build"))
F.onWrite("*config/term/zsh/theming/src/projects-build", executeCommand("projects-build"))
```
These glob patterns still reference `config/` paths (old structure).

**Reorg** (R061) moved the file from `config/vim/nvim/config/filetypes/colors.lua` to `tools/vim/nvim/config/config/filetypes/colors.lua`. The R061 score means the file content was also changed by reorg — likely updating existing path references inside it from `config/` to `tools/`.

## Resolution

1. Accept the merge with both sides' changes
2. Add main's two new `onWrite` lines, but update their glob patterns:
   ```lua
   F.onWrite("*tools/term/zsh/config/theming/src/projects.json", executeCommand("projects-build"))
   F.onWrite("*tools/term/zsh/config/theming/src/projects-build", executeCommand("projects-build"))
   ```
3. Check any other `config/` references in the file that reorg already updated, make sure they weren't lost

## Acceptance criteria

- [ ] No `<<<<<<` markers
- [ ] Two new `projects-build` `onWrite` entries present
- [ ] Both new entries use `tools/term/zsh/config/theming/src/` glob prefix
- [ ] No remaining `~/.oroshi/config/` hardcoded paths in the file

## Blocked by

issue-001
