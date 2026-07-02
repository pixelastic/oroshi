## TLDR

Fix `ctrl-p` silently doing nothing when run outside a git repository.

## What to build

Guard the `git-directory-root` call in the `ctrl-p` fzf script with `|| true`
so that `set -e` does not abort the script when `git-directory-root` returns
exit code 1 (its documented behavior outside a git repo).

`git-directory-root` already echoes `$PWD` as its output in that case, so
`SEARCH_PATH` is set correctly — the only thing needed is to prevent `set -e`
from treating the non-zero exit as fatal.

Add a bats test to the existing `ctrl-p` test suite that runs `ctrl-p --source`
from a plain non-git directory (a sibling of `$BATS_TMP_DIR`, created inline in
the test) and asserts the script exits successfully and lists files.

## Behavioral Tests

**Outside a git repository:**
- `fzf-source: works in non-git directory, uses cwd as search root` — exit status 0, output contains a file created in that directory

## Acceptance criteria

- [ ] `ctrl-p --source` run from a non-git directory exits with status 0
- [ ] `ctrl-p --source` run from a non-git directory lists files from `$PWD`
- [ ] `ctrl-p --source` run from a git repository still lists files from the git root (existing behavior unchanged)
- [ ] New bats test passes
- [ ] Existing bats tests still pass
