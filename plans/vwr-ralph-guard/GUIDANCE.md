## Guidance

### Goal

Add a `ralph-is-running` helper that detects an active ralph session in a plan directory, use it to hard-block `git-worktree-delete` from deleting a worktree mid-session, and refactor `ralph-single` to use the same helper.

### File locations (relative to repo root)

- Ralph bin scripts: `scripts/bin/ai/ralph/`
- Ralph lib (sourced by ralph): `scripts/bin/ai/ralph/__lib/`
- Ralph tests: `scripts/bin/ai/ralph/__tests__/`
- `git-worktree-delete`: `tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-delete`
- `git-worktree-delete` tests: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-delete.bats`

### Testing commands

```
bats scripts/bin/ai/ralph/__tests__/ralph-is-running.bats
bats scripts/bin/ai/ralph/__tests__/ralph-single.bats
bats tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-delete.bats
```

### Linting commands

```
zsh-lint scripts/bin/ai/ralph/ralph-is-running
bats-lint scripts/bin/ai/ralph/__tests__/ralph-is-running.bats
zsh-lint scripts/bin/ai/ralph/__lib/ralph-single.zsh
bats-lint scripts/bin/ai/ralph/__tests__/ralph-single.bats
bats-lint tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-delete.bats
```

### Conventions

- `ralph-is-running` is a bin script with `#!/usr/bin/env zsh` shebang and `set -e` (not `setopt local_options err_return` — that's for autoload functions)
- `git-worktree-delete` is a zsh autoload function: uses `setopt local_options err_return`
- `ralph-single.zsh` is sourced (not executed): uses `setopt local_options err_return`
- Use `local var="$(cmd)"` + manual guard for variable assignment (never split `local`/assignment)
- Use `[[ $isXxx == "1" ]]` for flag boolean tests (not arithmetic)
- Use `if/then/fi` for blocks with 2+ instructions; `&&` only for single-action one-liners
- Plans live inside the branch worktree at `<worktreePath>/plans/<branchSlug>`
- `ralph-is-running` is silent — no output, exit code only

### Prior art

- `ralph-state.bats` — pattern for ralph script tests using `bats_tmp_dir`
- `ralph-single.bats` — pattern for tests that mock `git-directory-root` and `claude`
- `git-worktree-delete.bats` — pattern for worktree tests using `bats_git_dir` / `bats_git_worktree`
- Existing unmerged-commits guard in `git-worktree-delete` — model for the ralph guard pattern

## Discoveries

<!-- Agents: append findings after each issue using the format below -->
<!-- ### Issue XX — short title -->
<!-- - Finding 1 -->
<!-- - Finding 2 -->

### Issue 02 — refactor ralph-single

- `bats_run_zsh "$CURRENT" "$PRD_DIR"` was the broken pattern — `bats_run_zsh` runs `zsh -c "$1"`, which tries to execute the file directly (requires execute bit + shebang); fix is `bats_run_zsh "ralph-single '$PRD_DIR'"` with the arg embedded in the command string
- `setup()` must still write to `mock.zsh` (via `printf "source ..."`) even without a `$CURRENT` caller — `bats_mock` sets `MOCK_OVERRIDE` to that file, zshenv sources it, which is how `ralph-single.zsh` gets defined in the subprocess
- In blocking tests, functions that are never reached (early return) should not be listed in `bats_mock` — they add misleading noise; only mock what the test path actually exercises

### Issue 01 — ralph-is-running

- `bats_run_zsh "$CURRENT" "$arg"` silently ignores `$arg` — bats_run_zsh only takes `$1` as the full command string; use `run <script> <args>` for bin scripts that need real arguments, reserve `bats_run_zsh` for mock-injected calls
- `return` at top-level of a zsh shebang script is equivalent to `exit` and is the idiomatic style in this codebase (plan-directory, ralph-state all use `return`)
- `plans/vwr-ralph-guard/ralph.json` exists during the session, so any test that calls `ralph-is-running` with no args in this worktree will find an active session — always pass explicit planDir or mock git helpers when testing the no-session path
