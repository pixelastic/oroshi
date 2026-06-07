## Guidance

### Goal

Make `tools/term/bats/config/helper` and `tools/term/bats/config/rules-helper` visible to bats-lint in all three lint contexts (NeoVim, `git-file-lint`, lint-staged), without renaming them.

### Commands

- **Run bats tests:** `bats <filepath>`
- **Run bats-lint:** `bats-lint <filepath>`
- **Run zsh-lint:** `zsh-lint <filepath>`

### Key files

- `tools/term/bats/config/helper` — BATS helper to fix (modeline + noRunZsh disables)
- `tools/term/bats/config/rules-helper` — BATS rules helper to fix (modeline + noRunZsh disables)
- `tools/term/zsh/config/functions/autoload/term/bats/` — target directory for new `is-bats` function
- `tools/term/zsh/config/functions/autoload/term/zsh/is-zsh` — direct model for `is-bats`
- `tools/term/zsh/config/functions/autoload/git/file/git-file-lint` — route bats files to bats-lint
- `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-lint.bats` — existing tests, add regression test here
- `scripts/yarn/lint-bats` — inner filter to update
- `~/.oroshi/lintstaged.config.js` — glob entry to update (note: lives in `$OROSHI_ROOT`, not the worktree)

### Conventions

- `is-bats` follows the return-early pattern and uses `setopt local_options err_return` (same as `is-zsh`)
- `is-bats` tests live at `tools/term/zsh/config/functions/autoload/term/bats/__tests__/is-bats.bats`
- Test files use `bats_load_library 'helper'`, set `CURRENT` in `setup()`, and use `bats_run_zsh "$CURRENT" "$file"` to invoke the function under test
- Per-line bats-lint disable: `# bats-lint disable=noRunZsh` on the line **above** the `run zsh` call
- The inline disable is handled by `lint-custom-run` — no changes to that function needed

### Prior art

- `is-zsh.bats` — canonical model for `is-bats` unit tests
- `git-file-lint.bats` — shows how to mock commands and assert routing behavior
- `rule-no-run-zsh.bats` — example of rule test structure (not directly relevant but useful context)

## Discoveries

_Append findings here after each issue, as `### Issue XX — short title` with bullet points._
