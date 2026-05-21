## Execution order

001 → start here, no blockers (shellcheck config migration)
002 → start here, no blockers (promote custom rule levels)
003 → start here, no blockers (is-zsh + tests)
004 → needs 003 (lint-zsh pre-commit)
005 → needs 003 (git-file-lint / vfl + tests)

## Guidance

- ZSH autoloaded functions: `config/term/zsh/functions/autoload/<domain>/<subdomain>/<name>` — no file extension, no shebang
- ZSH scripts: `scripts/bin/` — with or without `.zsh` extension, shebang `#!/usr/bin/env zsh`
- Yarn scripts (pre-commit runners): `scripts/yarn/` — shebang `#!/usr/bin/env zsh`, `set -e`, takes file paths as `$@`
- Bats tests live at `<same-dir-as-function>/__tests__/<function-name>.bats`
- Use `bats_load_library 'helper'` in test files; use `bats_run_function` to call autoloaded functions
- Use `bats_git_dir` / `bats_git` helpers to set up temp git repos in tests
- `OROSHI_ROOT` is always set in the ZSH environment — use it to build paths to config files
- Prior art for path-inspection tests: `scripts/bin/term/bats/__tests__/bats-test-path.bats`
- Prior art for dirty-file function tests: `config/term/zsh/functions/autoload/git/file/__tests__/git-file-list-dirty-raw.bats`
- `git-file-list-dirty-raw` outputs lines in format `STATUS:relative/path`; status D = deleted
- `zshlint` takes multiple file paths as arguments, exits 1 on any violation, outputs JSON array
- The `jq` formatter for `git-file-lint` output: `.[] | "\(.file):\(.line):\(.column): \(.code): \(.message)"` (adapt field names to actual zshlint JSON shape)
- Bats tests must `cd` into temp repo dirs before git operations (pre-commit hook sets `GIT_DIR=.git` as relative path)
- Never split `local` declaration and assignment — use `local var="$(cmd)"` pattern
- Use `setopt local_options errexit` (not `set -e`) inside autoloaded functions

---
## Log (append below when an issue is completed)

## Session 2026-05-21 — 0003: is-zsh
- Completed: new autoloaded function `term/zsh/is-zsh` with 5-rule detection; bats test suite with 8 cases
- Tests added: `config/term/zsh/functions/autoload/term/zsh/__tests__/is-zsh.bats` (8 tests)
- Discovered: spec rule 1 covers symlinks but no acceptance criterion existed for it; added test for symlink → exit 1
- Fixed: review caught `errexit` → `err_return` (autoload functions must not call `exit`); added guard after `local firstLine="$(head -1 ...)"` per variables.md; added symlink check per spec
- Skipped feedback: none
- Next: issue 004 (lint-zsh pre-commit hook, depends on is-zsh)
