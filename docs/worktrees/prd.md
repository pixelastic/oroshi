# PRD — Git Worktree Toolbox v2

## Problem Statement

The worktree toolbox (v1) has several rough edges that make daily use friction-ful:

1. **Wrong directory names**: `git-worktree-create` derives the repo name from the
   folder name, which gives `.oroshi--fix_bug` instead of `oroshi--fix_bug` for
   dot-prefixed repos like `~/.oroshi`.
2. **Verbose aliases**: `vwtc/vwtl/vwts/vwtR` have an extra `t` that slows typing
   and is inconsistent with the rest of the `v` alias family.
3. **`vwR` suggests `main`**: autocomplete for delete incorrectly offers `main`,
   which cannot be deleted.
4. **`vwl` is too bare**: lists branch names only — no ahead/behind vs main, no date,
   no commit message. Not useful at a glance.
5. **Prompt is blind to worktrees**: when inside a worktree the prompt shows a raw
   filesystem path instead of the parent project prefix, and doesn't communicate
   the worktree's relation to `main`.
6. **No `vwsm` shortcut**: returning to the Git Repo Main requires typing `vws main`.

## Solution

Seven targeted improvements to functions, aliases, completion, and prompt:

1. A new `git-github-remote-name` helper provides the canonical repo name (from
   remote URL, falling back to folder name with dots stripped).
2. Aliases shortened to `vwc/vwl/vws/vwR` + new `vwsm`.
3. Separate completion sets: with `main` (for switch) and without (for delete).
4. `vwl` enriched with ahead/behind vs `main`, relative date, and last commit message.
5. `GIT_DIRECTORY_IS_WORKTREE` cached in env (like `GIT_DIRECTORY_IS_REPOSITORY`).
6. New `git-worktree-project` helper maps a worktree back to its parent project.
7. Prompt left side: worktree leaf icon + branch name after project prefix; right
   side: branch hidden when already shown on the left.

## User Stories

1. As a developer, I want `vwc fix/bug` to create a worktree named `oroshi--fix_bug`
   (not `.oroshi--fix_bug`), so that the directory is not hidden.
2. As a developer, I want `vwc`, `vwl`, `vws`, `vwR` as short aliases, so that I
   type fewer characters for the most frequent operations.
3. As a developer, I want `vwsm` to take me back to the Git Repo Main immediately,
   so that I don't have to remember `vws main`.
4. As a developer, I want autocomplete for `vwR` to never suggest `main`, so that
   I can't accidentally try to delete the Git Repo Main.
5. As a developer, I want `vwl` to show ahead/behind counts vs `main` for each
   worktree, so that I can see at a glance which ones have diverged.
6. As a developer, I want `vwl` to show the date of the last commit in each
   worktree, so that I can tell which ones I haven't touched in a while.
7. As a developer, I want `vwl` to show the last commit message for each worktree,
   so that I can recall what work was in progress without switching to it.
8. As a developer, I want `vwl` to mark the worktree I am currently in, so that I
   can orient myself within the list.
9. As a developer, I want the prompt to show the parent project prefix when I am
   inside a worktree, so that I always know which project I am working on.
10. As a developer, I want a leaf icon before the branch name on the left prompt
    when I am in a worktree, so that I can tell at a glance that I am not in the
    Git Repo Main.
11. As a developer, I want the leaf icon to be orange when the worktree has no
    commits ahead of `main`, so that I know the branch is still in sync.
12. As a developer, I want the leaf icon to turn purple when the worktree has
    commits ahead of `main`, so that I know there is work to eventually merge.
13. As a developer, I want the branch name to appear on the left prompt (next to
    the leaf icon) when in a worktree, so that I see it as a physical location,
    not a volatile git state.
14. As a developer, I want the branch name hidden from the right prompt when I am
    in a worktree, so that it is not shown twice.

## Implementation Decisions

### Module 1 — `git-github-remote-name` (new, `git/github/` family)

Returns the repository name as a single word.

- Primary source: parse the GitHub remote URL of the current remote
  (`git remote get-url <remote>`), extracting the last path component and
  stripping the `.git` suffix. Works for both SSH (`git@github.com:owner/repo.git`)
  and HTTPS (`https://github.com/owner/repo.git`) forms.
- Fallback (no remote or non-GitHub remote): take the folder name of the Git Repo
  Main and strip all leading dots (e.g. `.oroshi` → `oroshi`).
- Sits alongside `git-github-remote-owner` (owner) and `git-github-remote-project`
  (slug) to complete the trio — matching Gilmore's `githubRepoName / githubRepoOwner
  / githubRepoSlug` naming convention.

### Module 2 — `git-worktree-create` update

Replace `${repoMain:t}` with a call to `git-github-remote-name`. No other logic
changes. Depends on Module 1.

### Module 3 — Alias rename + `vwsm`

`worktree.zsh` alias file: rename `vwtc→vwc`, `vwtl→vwl`, `vwts→vws`,
`vwtR→vwR`. Add `vwsm` as an alias for `vws main`.

`compdef.zsh` needs no changes: completions are bound to functions, not aliases.

### Module 4 — `complete-git-worktrees-linked` (new) + compdef split

New completion function `complete-git-worktrees-linked`: wraps
`git-worktree-list-raw`, outputs branch names only — no `main`.

`_git-worktrees-linked` compdef wrapper delegates to it.

In `compdef.zsh`:
- `git-worktree-switch` keeps `_git-worktrees` (includes `main`)
- `git-worktree-delete` switches to `_git-worktrees-linked` (excludes `main`)

### Module 5 — `git-worktree-distance` (new, `git/worktree/` family)

Returns the ahead/behind commit count between the current worktree branch and
`main`. Wraps `git rev-list --left-right --count main...HEAD`.

Output format mirrors `git-branch-distance` (`"ahead X, behind Y"`) so that
`git-distance-colorize` can consume it directly without adaptation.

Used by both `git-worktree-list` (module 6) and `git_worktree_branch` (module
10). Extracting it as a standalone helper avoids duplicating the git call and
makes the distance independently testable.

### Module 6 — `git-worktree-list` enriched

Rewrite to follow the same column pattern as `git-branch-list` (uses `table` with
`▮` separator, same colorize helpers).

Columns per row:
1. Current worktree marker (▶ or blank)
2. Branch name — `git-branch-colorize --with-icon`
3. Ahead/behind vs `main` — `git-distance-colorize --with-icon`
   (computed with `git rev-list --left-right --count main...HEAD`)
4. Relative date of last commit — `git-date-colorize --with-icon`
5. Last commit message — `git-message-colorize`

Current worktree detection: compare `$PWD` to the worktree path from
`git-worktree-list-raw`.

### Module 7 — `GIT_DIRECTORY_IS_WORKTREE` env cache

Add to `oroshi-git-env-store` (precmd hook, alongside `GIT_DIRECTORY_IS_REPOSITORY`):

```
GIT_DIRECTORY_IS_WORKTREE="$(git-directory-is-worktree && echo 1 || echo 0)"
```

Update `oroshi-prompt-populate:git_is_worktree` to read `$GIT_DIRECTORY_IS_WORKTREE`
instead of calling `git-directory-is-worktree` directly.

### Module 8 — `git-worktree-project` (new, `git/worktree/` family)

Returns the project name for the current worktree.

```
git-worktree-main → project-by-path <mainPath>
```

Returns empty string if the Git Repo Main does not match any known project.
Used by the prompt; can also be called standalone.

### Module 9 — `oroshi-prompt-populate:path` update

Replace the `project-by-path` call with branching logic:

- If `GIT_DIRECTORY_IS_WORKTREE == 1` → call `git-worktree-project`
- Else → call `project-by-path $PWD` (unchanged)

Path display after the prefix: relative to the worktree root (same behaviour as
relative-to-project-root today). No branch name in the path segment.

### Module 10 — Worktree branch prompt part (new: `git_worktree_branch`)

New **asynchronous** prompt part `git_worktree_branch`. Replaces
`git_is_worktree` (which is retired).

When `GIT_DIRECTORY_IS_WORKTREE == 1`, outputs:

```
<leaf-icon-colored> <branch-name-colored>
```

- Leaf icon color: `COLOR_ALIAS_GIT_WORKTREE` (orange) when 0 commits ahead of
  `main`; `COLOR_ALIAS_GIT_TRACKED` (purple) when ≥ 1 commit ahead of `main`.
  Ahead count: `git rev-list --count main..HEAD`.
- Branch name: colorized via `git-branch-colorize` (no icon — the leaf icon
  already carries the worktree signal).
- Icon: `` (\uf06c) — Nerd Fonts leaf glyph.

When not in a worktree, outputs empty string.

`git_branch` (right prompt) suppressed when `GIT_DIRECTORY_IS_WORKTREE == 1`.

Remove `git_is_worktree` from `OROSHI_SYNCHRONOUS_PROMPT_PARTS`.
Add `git_worktree_branch` to `OROSHI_ASYNCHRONOUS_PROMPT_PARTS`.
Remove `git_branch` display from `oroshi-prompt-right` when in worktree (guard
with `$GIT_DIRECTORY_IS_WORKTREE`).

## Testing Decisions

Good tests verify observable behaviour from the outside — exit codes, stdout, and
side-effects (directory created, branch exists). They do not assert on internal
variable names or call sequences.

Prior art: all bats tests in `scripts/bin/__tests__/`, using `load 'test_helper/zsh'`
and `run_zsh_fn`. Temp repos built with `bats_tmp`.

Modules with bats tests:

- **`git-github-remote-name`** — 4 tests: SSH URL, HTTPS URL, no-remote fallback,
  dot-prefix stripping.
- **`git-worktree-create`** (naming regression) — 1 test: creates directory without
  leading dot when repo folder is dot-prefixed.
- **`complete-git-worktrees-linked`** — 3 tests: excludes `main`, includes linked
  branches, empty when no worktrees.
- **`git-worktree-list`** (enriched) — 5 tests: current marker, ahead count, behind
  count, relative date present, commit message present.
- **`GIT_DIRECTORY_IS_WORKTREE` cache** (via `oroshi-git-env-store`) — 2 tests:
  equals 1 inside linked worktree, equals 0 in Git Repo Main.
- **`git-worktree-project`** — 2 tests: returns project name for known project,
  returns empty for unknown project.

Prompt parts (`oroshi-prompt-populate:path`, `git_worktree_branch`) are not unit
tested — their behaviour is covered indirectly by the helper tests above.

Alias config (`vwc/vwl/vws/vwR/vwsm`) tested via the existing config test
pattern in `git-worktree-config.bats`.

## Out of Scope

- Merging `vbs`/`vbc` with worktree creation (kept separate until the worktree
  workflow is fully understood).
- Showing ahead/behind status in the worktree icon on the Claude statusline (requires
  changes outside this codebase).
- `vwl` showing a diff summary vs `main` (listed as "maybe later" in the todo).
- Choosing the exact leaf glyph for the worktree icon (user decision at
  implementation time).

## Further Notes

- Domain glossary: `docs/worktrees/CONTEXT.md`
- ADRs in scope: `adr/0001` (global store), `adr/0002` (delete decoupled from branch)
- Execution order for issues:
  - 0001 `git-github-remote-name` — no blockers
  - 0002 `git-worktree-create` naming fix — needs 0001
  - 0003 alias rename + `vwsm` — no blockers
  - 0004 `complete-git-worktrees-linked` — no blockers
  - 0005 `git-worktree-distance` — no blockers
  - 0006 `git-worktree-list` enriched — needs 0005
  - 0007 `GIT_DIRECTORY_IS_WORKTREE` cache — no blockers
  - 0008 `git-worktree-project` — no blockers
  - 0009 `oroshi-prompt-populate:path` update — needs 0007 + 0008
  - 0010 `git_worktree_branch` prompt part — needs 0005 + 0007
