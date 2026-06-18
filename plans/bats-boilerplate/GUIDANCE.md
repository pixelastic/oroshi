## Guidance

- **Test command (bats):** `bats <filepath>`
- **Lint command (bats):** `bats-lint <filepath>`
- **Lint command (zsh):** `zsh-lint <filepath>`
- **Helper file:** `tools/term/bats/config/helper`
- **Helper tests:** `tools/term/bats/config/__tests__/helper.bats`
- **Lint rules dir:** `scripts/bin/term/bats/bats-lint/__rules/`
- **Lint rules loader:** `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh`
- **Rules test helper:** `tools/term/bats/config/rules-helper`
- **Prior art for rule tests:** `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-run-zsh.bats`
- **Only non-trivial teardown:** `tools/ai/rtk/__tests__/rtk.bats` — do not touch during migration
- BATS runs in bash, not zsh — helper functions are bash functions
- `bats_load_library 'helper'` is always the first line in `.bats` files; test file definitions come after and override helper definitions
- Use `bats_run_zsh` (not `run zsh -c`) to invoke zsh commands from tests
- Use `bats_mock` for deep mocking — serializes bash functions to `mock.zsh`
- Rule API: function receives file path, outputs `file▮code▮level▮line▮message` (▮ = `$_SEP`, U+25AE)

## Discoveries

_(append-only — updated by agents after each issue)_

### Issue 01 — Harden helper
- Default teardown test needs its own `.bats` file — can't test "no teardown defined" in a file that defines one
- `rm -rf ""` returns 0 in bash (no stderr), so the guard is defensive, not fixing an observable failure on this system
