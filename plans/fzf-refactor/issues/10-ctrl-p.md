## TLDR

Migrate files-in-project search (Ctrl-P) to a FZF Script, with simplified-path display backported from the skills-reference worktree.

## What to build

Create `scripts/bin/fzf/ctrl-p` — the most complex FZF Script. It sources `helpers/fs.zsh`,
`helpers/git.zsh`, and `helpers/prompt.zsh`.

**Core behaviour:** searches files in the git repository root and returns an absolute path.

**Simplified-path display (backported from `oroshi--skills-reference`):**
The current legacy system couples display and search via `--with-nth`, making truncated path
segments unsearchable. The new implementation decouples them using a cache-and-filter pipeline:

1. `fzf-source` writes the full list of relative paths to a per-project cache file (keyed by git root)
2. `fzf-options` sets `--disabled` and `--bind=change:reload` pointing to the script's `--format` stage
3. A `--format` stage (called on each keystroke via reload) reads the cache, applies `fzf --filter`
   on untruncated paths, and outputs two-column lines: `absolute-path<TAB>simplified-display-path`
4. fzf displays column 2 (simplified); `fzf-postprocess` extracts column 1 (full path)

This means any segment of any path is searchable regardless of display truncation.

**Context-aware Ctrl-P pickers** (from `oroshi--completion-ctrlp`):
The CTRL_P_PICKERS registry already updated in the completion-ctrlp worktree is backported here.
When the command line contains a recognised command (e.g. `vfa` → git-stageable files,
`bats` → bats test files), Ctrl-P dispatches to the appropriate FZF Script instead of the
default file search.

Update the Ctrl-P ZSH keybinding widget.
Update Neovim's `disk.lua` Ctrl-P binding to use the Neovim API.
Delete legacy autoloads for `fs/files/project/` and `fs/files/shared/`.
Delete legacy autoloads for `git/files-stageable/` and `bats/` (their pickers are now
called via the registry, not directly from legacy autoloads).

## Behavioral Tests

**fzf-source**
- Given a git repository, outputs all tracked and untracked (non-ignored) files
- Writes a cache file at a deterministic path keyed by git root
- Each output line contains the full relative path (not truncated)

**fzf-postprocess**
- Given a two-column line `<absolute-path><TAB><display-path>` on stdin, outputs the absolute path
- Given empty stdin, outputs nothing
- Handles paths with spaces correctly

**Format stage (reload target)**
- Given a query string, reads the cache and applies fuzzy filter
- Outputs two-column lines even when query is empty (shows all files)
- Matches on full path, not just the display path

## Acceptance criteria

- [ ] `scripts/bin/fzf/ctrl-p` created as executable `#!/bin/zsh` script
- [ ] `ctrl-p --source` outputs project files and writes cache
- [ ] `ctrl-p --options` outputs `--disabled` and `--bind=change:reload` pointing to format stage
- [ ] `ctrl-p --postprocess` (stdin) extracts absolute path from two-column selection
- [ ] Typing a deep path segment that is truncated in the display still matches correctly
- [ ] Ctrl-P with `vfa` on the command line dispatches to git-stageable picker
- [ ] Ctrl-P with `bats`/`rtk bats` on the command line dispatches to bats-test picker
- [ ] BATS tests for `fzf-source`, format stage, and `fzf-postprocess` pass
- [ ] Ctrl-P ZSH widget updated to call new script + registry
- [ ] Neovim Ctrl-P updated to use Neovim API (`ctrl-p --source`, `ctrl-p --options`, `ctrl-p --postprocess`)
- [ ] Legacy autoloads for `fs/files/project/`, `fs/files/shared/`, `git/files-stageable/`, `bats/` deleted
- [ ] `zshlint` passes on all modified files
