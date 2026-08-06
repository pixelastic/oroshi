## Guidance

- No tests for this plan — all artifacts are config files, a deploy script, and a trivial wrapper
- Deploy scripts use `#!/usr/bin/env bash` with `set -ex` (see `tools/git/git/deploy` for reference)
- Autoload functions use `setopt local_options err_return` (see `git-file-lint` for reference)
- Aliases live in `tools/term/zsh/config/aliases/git/file.zsh`
- `hunk` binary is on PATH via `$OROSHI_ROOT/node_modules/.bin/` — call it as `hunk`, not by full path
- Config symlink target: `~/.config/hunk/config.toml`
- `git-directory-root` returns the git root of the current repo

## Discoveries

_None yet._
