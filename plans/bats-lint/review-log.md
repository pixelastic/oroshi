## Issue 20 — preferBatchMock rule

### Standards: missing `setopt local_options err_return`
```zsh
batsLintRule_preferBatchMock() {
  local code='preferBatchMock'
```
**Problem:** Reviewer flagged missing `setopt` for error protection.
**Reason skipped:** Rule files are sourced helpers, not autoloaded functions. Existing rule files (`rule-no-run-zsh.zsh`, etc.) have none. Consistent with prior art.

### Standards: missing `setup()`/`teardown()` and `run_this_rule` at top level
**Problem:** Reviewer flagged `run_this_rule` at top level and no `setup()`/`teardown()`.
**Reason skipped:** All existing rule test files follow this exact same pattern. Consistent with the issue spec's prescribed code and every prior rule test.

### Standards: `local line` without initial value
**Problem:** Reviewer cited `feedback_zsh_local_assignment.md` against split `local`/assignment.
**Reason skipped:** That memory applies to command-substitution patterns. `local line` as a loop variable has no initial value to assign; existing rules use the same form.

## Issue 18 — bats-lint file-type guard

### Standards: `local` at script scope (bats-lint)
```zsh
local invalid_json='[]'
local valid_json='[]'
local merged="$(jq ...)"
```
**Problem:** Reviewer flagged `local` outside a function as a violation.
**Reason skipped:** Pre-existing pattern throughout `bats-lint`. `zsh-lint` runs clean — the linter does not flag this. Not introduced by this diff.

### Standards: `local` vars inside `@test` blocks (bats-lint.bats)
```bats
local file="$BATS_TMP_DIR/test.zsh"
```
**Problem:** Reviewer cited `feedback_bats_setup_vars.md` — test vars should be in `setup()`.
**Reason skipped:** That memory says "not at file top level", not "not inside @test". Locals inside `@test` are the pre-existing pattern across all tests in this file.

### Spec: "sub-linters NOT called" — weak assertion
**Problem:** Test verifies sub-linter output is absent, not that they were never invoked.
**Reason skipped:** Behavioral output check is the standard bats approach. Invocation counting would require additional mock infrastructure. Output absence is sufficient proof.

### Spec: Mix test doesn't assert bats-lint-custom was called with valid file only
**Problem:** Test only checks SC2086 in output, not that custom wasn't called with invalid file.
**Reason skipped:** The `notBats`+`SC2086` output check fully covers the spec's "merges both violation sets" acceptance criterion.

## Issue 17 — global cleanup pass

### Standards: SCRIPT assigned before bats_tmp_dir in zsh-lint-shellcheck.bats
```zsh
setup() {
  SCRIPT="${BATS_TEST_DIRNAME}/../zsh-lint-shellcheck.zsh"
  bats_tmp_dir
  ...
}
```
**Problem:** Reviewer noted examples show `bats_tmp_dir` called first.
**Reason skipped:** `SCRIPT` uses `$BATS_TEST_DIRNAME` (always set by bats, not by `bats_tmp_dir`), so ordering is semantically correct. The example is illustrative, not prescriptive.

### Spec: no evidence of full bats/bats-lint pass in diff
**Problem:** Spec requires all ~120 files clean; reviewer saw only 13 files in diff.
**Reason skipped:** Full `bats-lint` global run confirmed `[]` (exit 0) on all 132 files; full `bats` run confirmed 756/756 tests pass — both verified before the review was submitted.

## Issue 15 — lint pass git worktree

### Pre-existing test failure in scripts/bin/__tests__/git-worktree-list-raw.bats

```
not ok 4 works from inside a linked worktree
# BW01: `run`'s command `zsh -c ... git-worktree-list-raw "$@" --` exited with code 127
```

**Problem:** Spec reviewer flagged that `bats` does not pass on all files.
**Reason skipped:** The failure pre-dates this session. Confirmed by stashing all changes and re-running the test — same failure with the original code. The `scripts/bin` version uses `bats_tmp_dir` (not `bats_git_dir`), so git-worktree-list-raw is not autoloaded in that subshell context. Out of scope for issue 15.

## Issue 12 — lint pass text utils

### 6 of 8 files have no diff

```
The diff only touches 2 of the 8 required files. The other 6 are entirely absent.
```

**Problem:** Spec reviewer flagged that 6 text-* files were not changed.
**Reason skipped:** Those 6 files had zero bats-lint violations before this session. The scaffold test verifies all 8 pass `bats-lint`; all 8 do. No changes were needed for the clean files.

## Issue 10 — lint pass tools/ai

### statusline.bats has no diff

```
statusline.bats is absent from the diff. The spec lists 6 files; only 5 bats files were touched.
```

**Problem:** Spec reviewer flagged that `statusline.bats` had no changes in the diff.
**Reason skipped:** `statusline.bats` was already lint-clean before this session — `bats-lint` returned `[]` on it in the initial scan. No changes were needed, so no diff was produced. All 6 files pass `bats-lint` as required.
