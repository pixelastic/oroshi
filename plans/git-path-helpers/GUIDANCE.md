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
- zparseopts pattern: `zparseopts -E -D -repo:=flagRepo` (no `zmodload` needed)
- Tests use `bats_git_dir` for temp repos, `bats_run_zsh` for execution

### Prior art
- `git-branch-remote` — `--repo` flag with zparseopts, tested in `git-branch-remote.bats`
- `git-file-list-dirty-raw` — positional `$1` path arg with `-C`
- `git-remote-url` — `--repo` flag with zparseopts

## Discoveries

### Issue 01 — Migrate branch scripts to autoload
- Autoload functions must use `return` not `exit` — `exit` kills the shell session
- `zmodload zsh/zutil` is unnecessary before `zparseopts` — it's an autoloadable builtin; removed from entire codebase
- No blank line between header comment block and `setopt local_options err_return`

### Issue 02 — Add path args to git helpers
- `git -C` must come before the subcommand (`git -C /path commit`), not after (`git commit -C /path` means reuse commit message)
- `git-remote-current` accepts positional `$1` for path (internally calls `git-branch-remote --repo`)
