## TLDR

Fix `sort-filepaths` so dotfiles sort after regular files at every level of the tree.

## What to build

In `sort-filepaths`, add a dotfile detection check (`[[ $name == .* ]]`) wherever a sort weight prefix is assigned to a filename. Dotfiles get sub-weight `b`, regular files get sub-weight `a`, so that regular files always sort before dotfiles within the same group:

- Root level: regular root files → `0a`, dotfile root files → `0b`
- DFS filename component: regular files → `0a${filename}`, dotfiles → `0b${filename}`

Directory components and `../` paths are unchanged. The existing contracts hold:
- Root files (both `0a` and `0b`) before DFS paths (`1…`)
- DFS files-before-subdirs ordering preserved
- `../` paths last (`2…`)

## Behavioral Tests

**Root level ordering**
- Dotfile at root sorts after regular file at root (e.g. `.fdignore` after `Makefile`)
- Dotfile at root sorts before any subdirectory file

**Subdirectory level ordering**
- Dotfile within a subdirectory sorts after regular file in the same subdirectory
- Dotfile within a subdirectory sorts before nested subdirectory files

**Existing contracts preserved**
- Root files still sort before subdirectory files
- Files at each level still sort before their subdirectories
- `../` paths still sort last
- Alphabetical ordering within the same sub-weight group is preserved

## Acceptance criteria

- [ ] Root dotfiles sort after regular root files
- [ ] Subdirectory dotfiles sort after regular files in the same directory
- [ ] All existing `sort-filepaths.bats` tests still pass
- [ ] New bats tests added for dotfile ordering at root and subdir level
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes on the test file
