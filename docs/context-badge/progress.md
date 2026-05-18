## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-002
issue-004 → needs issue-003
issue-005 → needs issue-001 + issue-002 (can run in parallel with issue-003/004)
issue-006 → needs issue-001 + issue-004 + issue-005
issue-007 → needs issue-002 (done last, in a separate worktree)

## Guidance

- Autoload functions live in `config/term/zsh/functions/autoload/project/`
- BATS tests live in `scripts/bin/__tests__/` — use `run zsh -c` with inline env var overrides (see `git-worktree-project.bats` and `oroshi-prompt-path-worktree.bats` as prior art)
- Worktree detection: always live via git commands on the given path; never read `$GIT_DIRECTORY_IS_WORKTREE`
- `--zsh` flag: set `OROSHI_IS_PROMPT=1` internally — do not export it, just set it for the duration of the function
- `project-by-path` must not be deleted until issues 004, 005, and the NeoVim part of 006 are all complete
- issue-007 (Claude Code statusline) is done in its own worktree and merged last; merge order: issue-004 first (test in shell), then the rest

---
## Log (append below when an issue is completed)
