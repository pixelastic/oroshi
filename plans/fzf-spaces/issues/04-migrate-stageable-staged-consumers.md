## TLDR

Migrate consumers of `dirty-stageable-raw` and `staged-raw` from `STATUS:filepath` to `filepath▮STATUS` parsing.

## What to build

Update these 4 consumers to split on `▮` instead of `:` and reverse column order:

**Consumers of `dirty-stageable-raw`:**
1. **`git-file-list-dirty-stageable`** — colorized display of stageable files
2. **`complete-git-files-dirty-stageable`** — zsh completion for stageable files
3. **`fzf-git-files-dirty-stageable`** — fzf picker for stageable files (the original bug trigger)

**Consumer of `staged-raw`:**
4. **`git-file-list-staged`** — colorized display of staged files

Same mechanical migration as issue 03.

The fzf picker `fzf-git-files-dirty-stageable` is the original bug trigger — after this issue, paths with spaces will display correctly, preview will work, and output will be clean.

## Scaffolding Tests

**`fzf-git-files-dirty-stageable.bats`** (update existing):
- existing preview tests still pass
- add test: source outputs paths with spaces without quotes
- add test: postprocess handles paths with spaces

## Acceptance criteria

- [ ] All 4 consumers parse `filepath▮STATUS` format
- [ ] No consumer uses `:` as separator for raw output
- [ ] `fzf-git-files-dirty-stageable` displays paths with spaces without quotes
- [ ] Existing fzf picker tests pass
- [ ] `zsh-lint` passes on all modified files
