## Guidance

### Testing commands
- `bats <filepath>` to run a single test file
- `bats-lint <filepath>` to lint a `.bats` file
- `zsh-lint <filepath>` to lint a zsh function

### File locations
- Git autoload helpers: `tools/term/zsh/config/functions/autoload/git/`
- Scripts to migrate: `scripts/bin/git/branch/`
- Test directories: `__tests__/` next to the functions they test

### Conventions
- Autoload functions use `setopt local_options err_return` (not `set -e`)
- Autoload functions have no shebang
- Path arg pattern: positional `$1` when no other arg exists, `--repo` flag via zparseopts when `$1` is taken
- `--repo` default: `git-directory-root` or current directory
- zparseopts pattern: `zmodload zsh/zutil` then `zparseopts -E -D -repo:=flagRepo`
- Tests use `bats_git_dir` for temp repos, `bats_run_zsh` for execution

### Prior art
- `git-branch-remote` — `--repo` flag with zparseopts, tested in `git-branch-remote.bats`
- `git-file-list-dirty-raw` — positional `$1` path arg with `-C`
- `git-remote-url` — `--repo` flag with zparseopts

## Discoveries
