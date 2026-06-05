## Issue 01 — bats_run_zsh helper

### realpath exits 0 on non-existent paths
```bash
local abs_path="$(realpath "$path")"
[[ "$abs_path" == "" ]] && return 1
```
**Problem:** Reviewer claimed `realpath` exits 0 on missing files so the guard never fires.
**Reason skipped:** On GNU/Linux (coreutils), `realpath` exits non-zero and writes nothing to stdout for missing paths. `local` swallows the exit code but `abs_path` is empty, so the guard fires correctly. macOS behavior differs but this codebase targets Linux.

### Stdin via <<< not explicitly forwarded
```bash
run zsh -c "$cmd" -- "$@"
```
**Problem:** Reviewer flagged that `run zsh -c` may not preserve stdin piped via `<<<`.
**Reason skipped:** Identical pattern used by existing `bats_run_function` and `bats_run_script`, which already support `<<<` in their usage docs. No regression introduced.

### Autoload fpath not set up in cmd string
```bash
run zsh -c "[[ -f '${mock_file}' ]] && source '${mock_file}'; ${func} \"$@\"" -- "$@"
```
**Problem:** Reviewer flagged that `.zshenv` is not sourced in the cmd, so fpath is not configured and autoload functions won't resolve.
**Reason skipped:** ZSH always sources `.zshenv` for non-interactive shells (`zsh -c` included). The exported `OROSHI_ROOT` causes `.zshenv` to pin fpath to the worktree — same mechanism `bats_run_function` relies on. No explicit source needed.
