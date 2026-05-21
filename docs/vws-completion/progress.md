## Execution order

issue-001 → start here, no blockers
issue-007 → start here, no blockers (independent of all others)
issue-002 → needs issue-001
issue-003 → needs issue-001
issue-004 → needs issue-001
issue-005 → needs issue-002 + issue-003 + issue-004
issue-006 → needs issue-002

## Guidance

- All autoload functions live in `config/term/zsh/functions/autoload/` under the appropriate subdirectory (`git/worktree/`, `completion/`, etc.)
- Bats tests live in a `__tests__/` subdirectory next to the function file
- Use `▮` (U+25AE) as the field separator throughout — never a plain pipe or comma
- Use `setopt local_options errexit` (not `set -e`) for autoload functions
- Use `local var="$(cmd)"` pattern for variable assignment — never split `local` from assignment, never group multiple locals on one line
- The `bats_git_dir` / `bats_git_worktree` helpers set up temp repos; always `cd` into the repo before running functions (pre-commit hook sets `GIT_DIR=.git` relative)
- `styling.zsh` is in `config/term/zsh/completion/styling.zsh` — add `zstyle` entries in the Git section following the existing branch pattern
- Prior art for distance tests: `git-worktree-distance.bats` (same setup, `git commit --allow-empty`)
- Prior art for completion tests: `complete-git-worktrees.bats` (existing file to update)

---
## Log (append below when an issue is completed)
