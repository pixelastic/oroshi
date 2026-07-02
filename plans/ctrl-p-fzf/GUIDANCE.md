## Guidance

**Plan:** Fix `ctrl-p` silently doing nothing outside git repositories.

**Root cause:** `scripts/bin/fzf/ctrl-p` uses `set -e`. `git-directory-root`
returns exit code 1 when outside a git repo (documented, tested contract).
The bare assignment `SEARCH_PATH="$(git-directory-root)"` propagates that
exit code, causing `set -e` to abort the script before fzf launches.

**Fix location:** `scripts/bin/fzf/ctrl-p` — one line, add `|| true` to the
`git-directory-root` assignment.

**Test location:** `scripts/bin/fzf/__tests__/ctrl-p.bats` — add one test
under the existing `fzf-source` section.

**Test conventions:**
- Use `bats_tmp_dir`, `bats_disable_worktree_aware`, `bats_run_zsh`
- Non-git sandbox: create a sibling dir with `local plainDir="${BATS_TMP_DIR}-plain"`
- The `setup()` already `git init`s in `$BATS_TMP_DIR`; the new test must use a
  directory outside that tree
- Clean up the sibling dir with `rm -rf "$plainDir"` at the end of the test

**Run tests:** `bats scripts/bin/fzf/__tests__/ctrl-p.bats`

**Lint:** `zsh-lint scripts/bin/fzf/ctrl-p` and `bats-lint scripts/bin/fzf/__tests__/ctrl-p.bats`

**Do NOT change `git-directory-root`** — its `return 1` on non-git dirs is
intentional and tested. Other callers already guard against it.

## Discoveries

<!-- append-only: agents add findings here after each issue -->
