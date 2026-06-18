## TLDR

Add `--preview` as a 4th standard flag in `init.zsh`, allow scripts to override `fzf-main`, and migrate `fzf-docker-images` to use `init.zsh`.

## What to build

**Extend `init.zsh`:**
- Add `--preview` flag parsing alongside `--source`, `--options`, `--postprocess`
- When `--preview` is passed, dispatch to `fzf-preview "$@"` (the script defines this function)
- `fzf-main` remains the default implementation; scripts with custom behavior override it with a comment explaining why

**Migrate `fzf-docker-images`:**
- Replace hand-rolled `zparseopts` + dispatch with `source init.zsh` + `fzf-main` call
- No functional change, just alignment with the standard pattern

**Update `ctrl-p` and `fzf-apt-packages`:**
- Source `init.zsh` for the 4 standard flags
- Add second `zparseopts` after init for custom flags (`--format`, `--cache-key`, `--git-root`, `--query` for ctrl-p; `--installed` for apt-packages)
- Override `fzf-main` with a `# Override fzf-main: <reason>` comment

**Inline preview in `fzf-git-files-dirty-stageable`:**
- Move `fzf-git-files-stageable-preview` logic into a `fzf-preview()` function inside the script
- Delete the standalone `fzf-git-files-stageable-preview` file
- Update `--preview` option to point to `fzf-git-files-dirty-stageable --preview {1}`

## Behavioral Tests

**init.zsh --preview dispatch**
- Given a script that defines `fzf-preview()`, calling with `--preview arg` invokes `fzf-preview` with `arg`
- Given a script without `fzf-preview()`, calling with `--preview` fails gracefully

## Acceptance criteria

- [ ] `init.zsh` parses `--source`, `--options`, `--postprocess`, `--preview`
- [ ] Scripts can override `fzf-main` after sourcing `init.zsh`
- [ ] `fzf-docker-images` uses `init.zsh` (no hand-rolled zparseopts)
- [ ] `ctrl-p` sources `init.zsh` + second `zparseopts` for custom flags
- [ ] `fzf-apt-packages` sources `init.zsh` + second `zparseopts` for `--installed`
- [ ] `fzf-git-files-dirty-stageable` has inline `fzf-preview()`, standalone preview file deleted
- [ ] `zsh-lint` passes on all modified files
