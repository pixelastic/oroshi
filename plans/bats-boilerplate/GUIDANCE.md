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

### Issue 02 — Lint rule noBoilerplateTeardown
- Suppression (`# bats-lint disable=`) is handled by the orchestrator (`lint-custom-run`), not individual rules — suppression tests must go through `bats-lint-custom`
- zsh-writer skill's Step 2 example still shows `teardown() { bats_cleanup }` — should be updated after migration (issue 03)

### Issue 04 — Fix bats-test-path teardown
- The ZDOTDIR hack was already dead code — `setup_file` looked for `zshenv.zsh` (renamed to `zshenv-host.zsh`/`zshenv-guest.zsh`), so it always early-returned
- `bats-test-path` has zero env dependencies — pure string manipulation via zsh parameter expansion, no OROSHI_ROOT mock needed
- Tests that point at live repo paths are brittle — sandbox the file structure in BATS_TMP_DIR instead
- Always use `bats_run_zsh` for zsh scripts even if they have a shebang — consistency + mock support

### Issue 05 — Fix statusline tests
- `bats_mock_oroshi_root` only affects zsh subprocesses (mock.zsh), not bash scope — `$OROSHI_ROOT` in bats test code still resolves to the real path
- Mock `colors-load-definitions` directly instead of recreating `dist/colors.zsh` on the filesystem — follows "mock collaborators, not filesystem" principle

### Issue 07 — Fix projects-build path quoting
- `bats_run_zsh "$filepath"` fails if the file lacks +x — use `bats_run_zsh "source '$filepath'"` for runtime-created scripts
- Existing `projects-list.zsh` convention: path values are double-quoted with literal tilde (`PROJECTS[x:path]="~/..."`) — build script must match
