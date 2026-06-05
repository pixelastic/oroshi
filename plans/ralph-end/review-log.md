## Issue 04 — ralph-dispatcher

### `return` used in script body (Standards)
```zsh
if [[ "$maxLoops" != "" ]]; then
  ralph-loop "$dir" "$maxLoops"
  return
fi
ralph-single "$dir"
```
**Problem:** reviewer flagged `return` outside a function in a `#!/usr/bin/env zsh` script.
**Reason skipped:** established codebase pattern — `ralph-start`, `ralph-state` all use `return` at script scope. Scripts are sourced via `bats_run_zsh` and in production via the caller chain.

### Test stub ordering (Spec)
```bash
ralph-single() { echo "SINGLE:$*"; }
bats_mock ralph-single ralph-loop
```
**Problem:** reviewer thought `bats_mock` resets function definitions to no-ops, breaking output assertions.
**Reason skipped:** `bats_mock` captures the current function body and writes it to `mock.zsh` before unsetting. Defining the stub BEFORE `bats_mock` is correct and required. Tests confirm the ordering works.

### `bats_run_zsh` instead of `bats_run_script` (Standards)
```bats
bats_run_zsh "$RALPH" "$PRD_DIR"
```
**Problem:** `ralph` is a bin script (has shebang); reviewer flagged that `bats_run_script` is the mandated helper for standalone scripts.
**Reason skipped:** `ralph-start.bats` and other bin-script tests in this repo use `bats_run_zsh`. The codebase pattern is `bats_run_zsh` for all scripts and functions.

### End-to-end acceptance criterion (Spec)
**Problem:** Spec criterion 5: "End-to-end: `ralph <dir>` runs a single issue; `ralph --max 1 <dir>` runs one loop iteration" — no automated test covers this.
**Reason skipped:** End-to-end integration requires a live Claude session. This is manual verification scope; unit tests cover dispatch routing.

### Directory default resolution untested (Spec)
**Problem:** `local dir="${${1:-.}:a}"` resolves `.` → cwd when no argument given; this path is not exercised by `ralph.bats` (tests always pass an absolute `$PRD_DIR`).
**Reason skipped:** The spec's behavioral tests only specify "calls `ralph-single` with the resolved directory" for an explicit `<dir>` argument. No-arg behavior is not a listed test case.

## Issue 03 — ralph-loop

### Spec: git-directory-root navigation is a "logic addition"

```zsh
local gitRoot="$(git-directory-root)"
cd "$gitRoot"
```

**Problem:** Spec says "extract the loop block from `ralph` verbatim — no logic changes." The `git-directory-root` navigation was shared setup code before the loop in `ralph`, not inside the loop block.

**Reason skipped:** Without navigating to git root, `git add --all` and `git commit` would fail in the extracted standalone function. This is a structural necessity (same pattern as `ralph-single.zsh`), not a logic change.

### Standards: `local commits` split from assignment in bats (SC2155)

```bats
local commits
commits="$(git -C "$GIT_REPO" log --oneline | wc -l)"
```

**Problem:** Memory rule says to combine `local`/assignment. Reviewer flagged initial combined form.

**Reason skipped:** The combined form `local commits="$(…)"` triggers SC2155 in shellcheck/bats-lint (bash context). The memory rule applies to ZSH functions only. Split form is correct for bats tests.

## Issue 02 — ralph-single

### Spec: bats_run_function not used

```bats
bats_run_zsh "$CURRENT" "$PRD_DIR"
```

**Problem:** Issue spec says "Write `ralph-single.bats` using `bats_run_function` (not `bats_run_script`)".

**Reason skipped:** `bats_run_function` is marked `DEPRECATED` in `tools/term/bats/config/helper` ("use `bats_run_zsh` with the full path to the autoload function instead"). The codebase migrated all tests to `bats_run_zsh` (commits `1a641105`, `47aa3f8a`). The actual prior art file `preToolUse-Bash-rtk.bats` uses `bats_run_zsh`. The spec was written before the migration.
