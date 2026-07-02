## Problem Statement

Pressing `ctrl-p` in a non-git directory (e.g. `~/perso/Dropbox/backup/roleplay`) does nothing — the fzf file picker silently fails to open.

The root cause: the `ctrl-p` fzf script uses `set -e` and calls `git-directory-root` to determine the search root. When run outside a git repository, `git-directory-root` echoes `$PWD` but explicitly returns exit code 1 (documented, tested contract: callers may use `$?` to detect non-git context). Under `set -e`, the assignment `SEARCH_PATH="$(git-directory-root)"` exits with code 1, and the script aborts silently before fzf ever launches.

## Solution

Guard the `git-directory-root` call in the `ctrl-p` script with `|| true` to prevent `set -e` from treating the expected non-zero exit as a fatal error. Since `git-directory-root` already echoes `$PWD` as a fallback when outside a repo, the search root will be set correctly in both cases.

Add a bats test that exercises `ctrl-p --source` from a plain (non-git) directory and asserts the script exits successfully and returns files.

## User Stories

1. As a user, I want `ctrl-p` to open the fzf file picker in any directory, so that I can search files regardless of whether I am inside a git repository.
2. As a user, I want `ctrl-p` in a non-git directory to search from the current working directory, so that the picker shows files relative to where I am.
3. As a user, I want `ctrl-p` in a git repository to continue searching from the git root, so that existing behavior is unchanged.
4. As a developer, I want a test that runs `ctrl-p --source` from a non-git directory and asserts it succeeds, so that this regression cannot be silently reintroduced.

## Implementation Decisions

- The fix is applied in the `ctrl-p` fzf script only. The `git-directory-root` function's contract (return 1 when outside a git repo) is intentional and remains unchanged — other callers already guard against it.
- The pattern `SEARCH_PATH="$(git-directory-root)" || true` is the minimal, idiomatic fix. It prevents `set -e` from aborting while leaving `SEARCH_PATH` set to the value already echoed by `git-directory-root` (`$PWD` in the non-git case).
- The existing fallback line `[[ "$SEARCH_PATH" == "" ]] && SEARCH_PATH="$PWD"` is retained as a safety net, even though `git-directory-root` never returns an empty string.

## Testing Decisions

Good tests exercise external behavior through the script's public interface (`--source`, `--options`, `--postprocess` flags) without inspecting internal variables or implementation details.

**Module under test:** `ctrl-p` fzf script (specifically the `--source` flag in a non-git directory context).

**New test:** a bats test in the existing `ctrl-p.bats` suite. It creates a sibling sandbox directory (non-git) alongside `$BATS_TMP_DIR`, touches a file in it, runs `ctrl-p --source` from that directory, and asserts:
- exit status is 0 (script does not abort)
- output contains the file (search actually ran)

**Prior art:** existing `ctrl-p.bats` tests use `bats_tmp_dir`, `bats_disable_worktree_aware`, `bats_run_zsh`, and the `▮`-delimited two-column output format as the assertion surface. The new test follows the same conventions.

## Out of Scope

- Changing the `git-directory-root` contract (return code or output behavior).
- Fixing any other fzf scripts (`ctrl-o`, `ctrl-g`, etc.) that may have the same latent issue — each should be diagnosed and fixed independently.
- Handling the case where `fd` is not installed.

## Further Notes

The `local var="$(cmd)"` idiom (used in ralph scripts) implicitly swallows the exit code because `local` always exits 0, making those callers immune to this bug. The `ctrl-p` script uses a bare assignment, which propagates the exit code and is thus susceptible.
