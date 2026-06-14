## Guidance

This plan removes two deprecated zsh environment variables (`ZSH_CONFIG_PATH`, `OROSHI_ZSH_AUTOLOAD`) that were removed from `zshenv` but still referenced in prod and test files.

**Replacements:**
- `$ZSH_CONFIG_PATH` → `$OROSHI_ROOT/tools/term/zsh/config`
- `$OROSHI_ZSH_AUTOLOAD/<subpath>/<fn>` → `$BATS_TEST_DIRNAME/../<fn>` (in `CURRENT=` assignments inside `setup()`)
- `$OROSHI_ZSH_AUTOLOAD/<subpath>/<fn>` → `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/<subpath>/<fn>` (in heredocs only — not applicable here, covered by `$ZSH_CONFIG_PATH` replacement)

**Testing commands:**
- `bats <filepath>` — run a bats test suite
- `zsh-lint <filepath>` — lint a zsh file
- `bats-lint <filepath>` — lint a bats file

**Conventions:**
- Heredoc delimiters in existing tests remain single-quoted (`<<'ZSCRIPT'`) — do not change quoting style
- `$BATS_TEST_DIRNAME` is available in `setup()`, `teardown()`, and test bodies; not inside subprocess scripts
- All `CURRENT=` assignments live inside `setup()`

**File locations (relative to repo root):**
- Prod: `tools/term/zsh/config/theming/index.zsh`, `scripts/bin/colors-refresh`
- Heredoc tests: `tools/term/zsh/config/prompt/__tests__/git.bats`, `tools/term/zsh/config/functions/autoload/git/branch/__tests__/git-branch-color.bats`
- CURRENT= tests: `tools/term/zsh/config/functions/autoload/colors/__tests__/colors-load-definitions.bats`, `tools/term/zsh/config/functions/autoload/colors/__tests__/colors-template-render.bats`, `tools/term/zsh/config/functions/autoload/term/js/__tests__/is-js.bats`, `tools/term/zsh/config/functions/autoload/json/__tests__/jsonc2json.bats`
- Cleanup: `TODO.md`

## Discoveries
