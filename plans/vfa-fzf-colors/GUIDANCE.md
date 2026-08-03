## Guidance

- FZF Helpers are `.zsh` files in `scripts/bin/fzf/__lib/`, named after the function they export
- FZF Helper tests go in `scripts/bin/fzf/__tests__/`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`
- Run bats tests: `bats <filepath>`
- Use `colorize --reply` to write to `$REPLY` instead of spawning a subshell
- `fzf-colorize-path` writes to `$REPLY` and takes `<displayPath> [realPath]`
- Color keys: `git-added`, `git-modified`, `git-removed` in `COLORS[]`
- The `▮` character is the FZF delimiter separating raw value from display column
- Prior art for FZF Helper with tests: `fzf-colorize-path.zsh` and its bats file

## Discoveries

_Append findings here after each issue._
