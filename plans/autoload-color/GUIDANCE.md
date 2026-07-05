## Guidance

### Goal

Color autoloaded ZSH functions (extensionless files under `functions/autoload/`) the same as `.zsh` scripts (violet-3, `FILETYPES[zsh:color]`) in both `exa`/`ls` output and the fzf file picker.

### Testing commands

- ZSH functions: `bats <filepath>`
- Lint ZSH: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`

### Key locations

- Autoload functions live under: `tools/term/zsh/config/functions/autoload/`
- New helper goes in: `tools/term/zsh/config/functions/autoload/term/zsh/`
- Helper tests go in: `tools/term/zsh/config/functions/autoload/term/zsh/__tests__/`
- `better-ls`: `scripts/bin/better-ls`
- `fzf-colorize-path`: `scripts/bin/fzf/__lib/fzf-colorize-path.zsh`
- `fzf-preview-header`: inside `scripts/bin/fzf/__lib/fzf-fs-preview.zsh`
- zsh-lint rule: `scripts/bin/zsh/zsh-lint/__rules/rule-missing-err-return.zsh`

### Conventions

- Autoload functions use `setopt local_options err_return` (not `set -e`)
- Functions returning a value write to `$REPLY` — no stdout, no subshell
- Bats test variables go inside `setup()`, not at file top level
- Use `bats_mock` to stub collaborators; never add env var overrides to prod code for test isolation
- Use `bats_run_zsh "fn args"` to call autoload functions in tests
- Use `$OROSHI_ROOT` for oroshi paths, never hardcoded `~/.oroshi`

### Prior art

- `is-zsh` — sibling helper, same structure as the new `is-zsh-autoload-function`
- `is-zsh.bats` — prior art for testing autoload helpers
- `fzf-colorize-path.bats` — prior art for testing fzf lib functions
- `rule-missing-err-return.bats` — prior art for testing zsh-lint rules

### Detection pattern

An autoloaded function is a file that:
1. Has no extension (`${path:e} == ""`)
2. Lives under a path matching `*/functions/autoload/*`

The shebang is NOT part of the detection — `is-zsh-autoload-function` does not check it.

## Discoveries

_Append findings here after each issue is completed._
