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

## Session 2026-05-22 — issue-001: Foundation helpers (context-project, context-root, context-path)
- Completed: created 3 autoloaded functions in `config/term/zsh/functions/autoload/project/`
- Tests added: `context-project.bats` (3 tests), `context-root.bats` (3 tests), `context-path.bats` (3 tests) in `project/__tests__/`
- Discovered: context-project must handle worktree paths (which live outside the registered project root) by detecting the worktree main repo via `git rev-parse --git-common-dir`
- Fixed: none
- Skipped feedback: reviewer flagged wrong test location (`scripts/bin/__tests__/`) — autoloaded function tests belong in `{domain}/__tests__/` per existing repo convention; reviewer flagged missing `setopt local_options errexit` — actually `err_return` per memory (fixed); reviewer said context-badge missing — that's issue-002, out of scope; reviewer said no independent tests needed per PRD — issue-001 acceptance criteria explicitly requires BATS tests
- Next: issue-002 (context-badge core — ANSI output)

## Session 2026-05-22 — issue-002: context-badge core (ANSI output)
- Completed: created `context-badge` autoload function in `config/term/zsh/functions/autoload/project/`
- Tests added: `context-badge.bats` (6 tests) in `project/__tests__/`
- Discovered: none
- Fixed: reviewer flagged `-z` → `[[ == "" ]]`, missing subshell guards, integer comparison style, `echo -n` → `print -n`; all applied
- Skipped feedback: `bats_run_function` suggestion — prior art (`context-project.bats`, `context-root.bats`) all use `run zsh -c` with inline env vars; `bats_run_function` has no env injection support; `--zsh` flag test — deferred to issue-003; trailing arrow background concern — reviewer misread, `\e[0m` after badge content already resets bg before trailing arrow; worktree path concat concern — `BATS_GIT_WORKTREES` has trailing slash per helper.bash, pattern matches prior art
- Next: issue-003 (context-badge --zsh flag)

## Session 2026-05-22 — issue-004: update-prompt

- Completed: replaced `project-colorize`/`project-by-path`/`git-worktree-project` in `path.zsh` with `context-badge --zsh`; replaced manual worktree path-stripping in `path_worktree_dir` with `context-path`; removed `git_worktree_branch` from async parts and `oroshi-prompt-left()` in `index.zsh`; deleted `oroshi-prompt-populate:git_worktree_branch` from `git.zsh`; removed 4 `git_worktree_branch` tests from `git.zsh.bats`
- Tests added: `path part contains branch name when inside a linked worktree`, `path_worktree_dir shows sub-path relative to worktree root` (in `path.zsh.bats`); `git_worktree_branch is not in OROSHI_ASYNCHRONOUS_PROMPT_PARTS` (in `index.zsh.bats`)
- Discovered: `path.zsh.bats` was sourcing `~/.oroshi/...` (main branch) instead of worktree — tests for sourced (non-autoloaded) prompt files must use `source $OROSHI_ROOT/config/...` to test worktree changes
- Fixed: pre-existing lint violations in `git.zsh` (`singleEqualsInTest` on `issueCount`/`pullrequestCount`, `noGroupedLocals` caused by inline `# In minutes` comment — moved to separate line)
- Skipped feedback: none
- Next: issue-005 (update-fzf)

## Session 2026-05-22 — issue-003: context-badge --zsh flag
- Completed: added `--zsh` flag to `context-badge` via `zparseopts`; dual output path (zsh `%K{}`/`%F{}` vs raw ANSI)
- Tests added: `--zsh flag output contains zsh prompt codes`, `--zsh flag output does not contain raw ANSI sequences`
- Discovered: `%k` must come before trailing end-cap arrow (not after) — arrow needs default bg to be visible; reviewer was mistaken
- Fixed: numeric comparison style `[[ $isZsh == 1 ]]` → `(( isZsh ))` for both isZsh and isWorktree
- Skipped feedback: `$'\e['` test flagged as `$'['` — reviewer hallucinated; test is correct; `%k` placement flagged — current placement is correct, moving it after arrow would make arrow invisible (branchBg fg on branchBg bg)
- Next: issue-004 (update-prompt)
