## TLDR

Delete the unused `fzf/projects/` autoload directory and the dead `oroshi-old.vim` VimScript file.

## What to build

Remove two bodies of dead code that reference the old project env var system but are called by nothing:

- The entire `fzf/projects/` autoload directory — contains `fzf-projects`, `fzf-projects-source`, `fzf-projects-options`, `fzf-projects-postprocess`, and their bats tests. No keybinding or script calls any of these.
- `oroshi-old.vim` — a VimScript colorscheme file that iterates `PROJECTS_INDEX` and reads `PROJECT_<KEY>_*` env vars. The Neovim statusline already uses the new system.

Nothing else needs to change. This slice has no blockers and no migration logic — it is a pure deletion.

## Acceptance criteria

- [ ] The `fzf/projects/` autoload directory and all its contents are deleted
- [ ] `oroshi-old.vim` is deleted
- [ ] No other file in the repo references any of the deleted functions or files
