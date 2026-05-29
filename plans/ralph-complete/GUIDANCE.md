## Guidance

### Testing
- Run bats tests: `bats <filepath>`
- Run zsh lint: `zshlint <filepath>`
- Run js lint: `yarn run lint:fix <filepath>`
- Prior art for bats tests: `fzf-claude-sessions-source-no-query.bats`, `fzf-fs-shared-preview-header.bats`
- Scaffold tests must be named `.scaffold.bats` and deleted before merging

### Conventions
- Autoloaded zsh functions live under `tools/term/zsh/config/functions/autoload/{domain}/`
- Compdef specs live under `tools/term/zsh/config/completion/compdef/`
- Compdef wiring lives in `tools/term/zsh/config/completion/compdef.zsh`
- `▮` (U+25AE) is the field separator for machine-readable (`-raw`) output
- Use `zparseopts` for named arguments, `local var="$(cmd)"` on one line
- Use `setopt local_options err_return` in autoloaded functions (not `set -e`)

### Key existing files
- `fzf-fs-shared-source`: supports `--max-depth` (added on this branch) — preserved but no longer used by the plans source
- `fzf-fs-directories-shared-postprocess`: expects `fullPath   displayName` (3 spaces separator) from FZF sources
- `ctrl-o.zsh`: dispatches CTRL-O to command-specific selection functions
- `_skills`, `_git-worktrees`: reference implementations for compdef wrappers

### Issue 02 note
The file `fzf-fs-directories-ralph-source.bats` was written on this branch as part of the `--max-depth` fix. It must be removed as part of issue 02 (the whole ralph directory is deleted). Replace with a `.scaffold.bats` in the new plans directory.

## Discoveries
