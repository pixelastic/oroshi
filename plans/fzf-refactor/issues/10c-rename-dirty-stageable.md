## TLDR

Rename `stageable` → `dirty-stageable` across the entire chain: helpers, FZF script, completion, and all callers.

## What to build

Rename the following files and all references to them:

**Autoloaded functions:**
- `git-file-list-stageable-raw` → `git-file-list-dirty-stageable-raw`
- `git-file-list-stageable` → `git-file-list-dirty-stageable`
- `complete-git-files-stageable` → `complete-git-files-dirty-stageable`

**FZF Script:**
- `scripts/bin/fzf/fzf-git-files-stageable` → `scripts/bin/fzf/fzf-git-files-dirty-stageable`

**Callers to update:**
- `ctrl-p.zsh` keybinding widget: `specialPickers` entry `vfa → fzf-git-files-dirty-stageable`
- Any completion config referencing `complete-git-files-stageable`

No behavioral change — pure rename.

## Acceptance criteria

- [ ] No file or function named `stageable` without the `dirty-` prefix remains
- [ ] `grep -r stageable scripts/bin/fzf/ tools/term/zsh/` returns zero hits (excluding this issue file)
- [ ] All callers updated to new names
- [ ] `zsh-lint` passes on all modified files
