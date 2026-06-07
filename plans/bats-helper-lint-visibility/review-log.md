## Issue 02 — wire lint pipeline

### Standards agent reviewed committed Issue 01 files, not dirty diff

**Problem:** Standards agent flagged `is-bats` (missing `# Usage:` label) and `is-bats.bats` (`$OROSHI_ROOT` path vs `$BATS_TEST_DIRNAME`) — both are committed Issue 01 files absent from the dirty diff.

**Reason skipped:** Out of scope for this review pass. The `$OROSHI_ROOT` path form is also consistent with all existing tests in this repo (e.g. `git-file-lint.bats` itself).

### Spec agent reported all changes as absent

**Problem:** Spec agent claimed `git-file-lint`, `lint-bats`, and `lintstaged.config.js` were not updated.

**Reason skipped:** Factually incorrect — `review-diff` output shows all four files changed. The agent failed to read the diff output.

## Issue 01 — is-bats and modeline

### Split local/assignment in `helper` (Standards)

```zsh
local slug
slug="$(bats_slugify "$BATS_TEST_DESCRIPTION")"
```

**Problem:** `variables.md` and `feedback_zsh_local_assignment.md` say to use `local var="$(cmd)"` on one line. Reviewer flagged the split form as a hard violation.

**Reason skipped:** `helper` is a bats/bash context file, not a ZSH autoload function. Shellcheck (SC2155) requires the split form in bash. The ZSH one-liner convention only applies to autoload functions. The split was introduced to fix pre-existing SC2155 violations.

### Disable comment syntax (Spec)

**Problem:** Spec says `# bats-lint disable=noRunZsh`; diff uses `# bats-lint-disable noRunZsh`.

**Reason skipped:** The actual parser format (from `lint-custom-run --disable-prefix bats-lint-disable`) produces `# bats-lint-disable <code>`. The implementation is correct — the spec description was inaccurate. `bats-lint` exits 0.

### `local firstLine="$(…)"` in `is-bats` (Spec)

**Problem:** Reviewer noted inconsistency with the split pattern used in `helper` in the same diff.

**Reason skipped:** `is-bats` is a ZSH autoload function where `local var="$(cmd)"` on one line IS the required convention. The split in `helper` was for bash/shellcheck context only.
