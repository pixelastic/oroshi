## Issue 02 — zshenv hardcode and rename

### OROSHI_WORKTREES_DIR_MOCK in production code
```zsh
export OROSHI_WORKTREES_DIR="${OROSHI_WORKTREES_DIR_MOCK:-$HOME/local/www/worktrees}"
```
**Problem:** Standards reviewer flagged this as a test-only concept leaking into production code, citing `feedback_no_env_var_mocks.md`.
**Reason skipped:** The issue spec explicitly mandates this pattern: "renamed to make test-only purpose explicit." The `_MOCK` suffix documents intent in the production file itself; bats_mock cannot intercept env var reads in subprocesses, so a named override is the only viable mechanism.

### Duplicate test bodies in zshenv.bats
```bats
@test "OROSHI_ROOT defaults to HOME/.oroshi when PWD is outside OROSHI_WORKTREES_DIR" { ... }
@test "OROSHI_ROOT defaults to HOME/.oroshi when unset and PWD is outside OROSHI_WORKTREES_DIR" { ... }
```
**Problem:** Spec reviewer noted both tests are now structurally identical after the rewrite of test #3.
**Reason skipped:** The spec explicitly requires both tests to exist (the rewrite of one and the rename of the other). Removing either would diverge from the spec. The duplication is an acknowledged trade-off of the hardcoding change.

## Issue 01 — bats_mock_oroshi_root

### CURRENT path uses $OROSHI_ROOT instead of $BATS_TEST_DIRNAME
```bats
export CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/icons/icons-load-definitions"
```
**Problem:** Reviewer flagged deviation from `$BATS_TEST_DIRNAME`-relative convention.
**Reason skipped:** Spec explicitly requires `$OROSHI_ROOT`-rooted path; `$BATS_TEST_DIRNAME`-relative paths would add fragile `../../..` traversal for deeply-nested autoload functions.

### bats-lint disable comment format change not in spec
```zsh
# bats-lint disable=noRunZsh
```
**Problem:** Reviewer noted the four comment format fixes are outside spec scope.
**Reason skipped:** Pre-existing lint errors in touched files must be fixed per project policy (feedback_lint_preexisting.md). The old `bats-lint-disable` syntax was silently not working; the new `bats-lint disable=` syntax is what lint-custom-run actually parses.

### Direct >> write to mock.zsh in test
```bats
echo 'typeset -gA ICONS; ICONS[prompt]=">"' >> "$BATS_TMP_DIR/mock.zsh"
```
**Problem:** Reviewer flagged bypassing helper API for the mock.zsh write.
**Reason skipped:** `bats_mock` uses `declare -f` which only serializes bash functions. Injecting zsh-specific `typeset -gA` syntax requires a direct write. No helper API exists for this case.
