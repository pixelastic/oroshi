## Guidance

### Goal

Give `vfrevert` (alias for `git-file-revert`) the same Tab completion and Ctrl-P fzf picker as `vfa`, and fix `git-file-revert` to correctly handle all dirty file states.

### Testing commands

```zsh
# Run bats tests
bats scripts/bin/fzf/__tests__/fzf-git-files-dirty.bats
bats tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-revert.bats

# Lint zsh files
zsh-lint scripts/bin/git/file/git-file-revert
zsh-lint scripts/bin/fzf/fzf-git-files-dirty
zsh-lint tools/term/zsh/config/functions/autoload/completion/complete-git-files-dirty
zsh-lint tools/term/zsh/config/completion/compdef/_git-files-dirty
```

### Key files and prior art

| New/modified file | Prior art to copy/adapt |
|---|---|
| `scripts/bin/git/file/git-file-revert` | itself — add per-file dispatch loop |
| `scripts/bin/fzf/fzf-git-files-dirty` | `scripts/bin/fzf/fzf-git-files-dirty-stageable` |
| `scripts/bin/fzf/__tests__/fzf-git-files-dirty.bats` | `scripts/bin/fzf/__tests__/fzf-git-files-dirty-stageable.bats` |
| `tools/.../autoload/completion/complete-git-files-dirty` | `tools/.../autoload/completion/complete-git-files-dirty-stageable` |
| `tools/.../completion/compdef/_git-files-dirty` | `tools/.../completion/compdef/_git-files-dirty-stageable` |
| `tools/.../completion/compdef.zsh` | line 93 — add after `_git-files-dirty-stageable` block |
| `tools/.../keybindings/ctrl-p.zsh` | `specialPickers` map — add `vfrevert fzf-git-files-dirty` |
| `tools/.../git/file/__tests__/git-file-revert.bats` | `tools/.../git/file/__tests__/git-file-list-dirty-raw.bats` |

Full paths use `$OROSHI_ROOT` prefix (`tools/term/zsh/config/...`).

### Key decisions

- `git-file-revert` dispatch: `git cat-file -e HEAD:"$file"` → checkout; `git ls-files --error-unmatch "$file"` → `git rm -f`; else → `rm`
- Data source for both picker and compdef: `git-file-list-dirty-raw` (lists ALL dirty files, staged + unstaged)
- compdef registers `git-file-revert` only — ZSH alias expansion makes `vfrevert` work automatically
- `specialPickers` registers `vfrevert` only — Ctrl-P matches the last buffer word, always the alias
- Label: "Dirty files" (both compdef header and fzf prompt)
- `git-file-revert` uses `set -e` (script with shebang, not autoload)

### Conventions

- fzf picker scripts: shebang `#!/usr/bin/env zsh`, `set -e`, source `__lib/init.zsh`
- autoload functions: no shebang, `setopt local_options err_return`
- bats tests: use `bats_git_dir` for real git repos; `bats_mock` for collaborator stubs; all vars in `setup()`

## Discoveries

<!-- Agents append findings here after each issue -->

### Issue 01 — Fix git-file-revert

- `git cat-file -e HEAD:"$file"` / `git ls-files --error-unmatch` elif chain is logically sound: the elif branch is only reached when case 1 fails, so matching ls-files unambiguously means staged-new.
- Tests for git bin scripts live in `tools/term/zsh/config/functions/autoload/git/file/__tests__/`, not alongside the script itself.
