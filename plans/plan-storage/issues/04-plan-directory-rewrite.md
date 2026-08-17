## TLDR

Rewrite `plan-directory` to resolve from `$OROSHI_PLANS_DIR` via `context-slug`, make it the single source of truth.

## What to build

**`plan-directory`** (`tools/term/zsh/config/functions/autoload/ai/plan/plan-directory`):

Rewrite to:
1. Accept same interface as `context-slug`: optional path arg, optional `--project`/`--branch` flags.
2. Pass all args through to `context-slug`.
3. Return `$OROSHI_PLANS_DIR/<context-slug-result>`.

**`git-worktree-has-plan`** (`tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-has-plan`):

Rewrite to delegate to `plan-directory`:
```
local planDir="$(plan-directory "$@" 2>/dev/null)" || return 1
[[ -f "$planDir/state.json" ]]
```

**`ralph-is-running`** (`tools/term/zsh/config/functions/autoload/ai/ralph-is-running`):

Update path resolution to use `plan-directory` when no explicit arg is given:
```
if [[ "$planDir" == "" ]]; then
  planDir="$(plan-directory 2>/dev/null)" || return 1
fi
```

## Behavioral Tests

**plan-directory.bats:**
- Returns `$OROSHI_PLANS_DIR/<slug>` when in a worktree
- Returns error when on main (no branch)
- Accepts `--project`/`--branch` overrides
- Result matches `$OROSHI_PLANS_DIR/$(context-slug)` exactly

**git-worktree-has-plan.bats:**
- Returns 0 when `state.json` exists in `$OROSHI_PLANS_DIR/<slug>/`
- Returns 1 when no `state.json` at that path
- Returns 1 when on main

**ralph-is-running.bats:**
- Returns 0 when `ralph.json` exists in external plan dir
- Returns 1 when no `ralph.json`

## Scaffolding Tests

- `plan-directory` no longer references `$wtRoot/plans/`
- `git-worktree-has-plan` no longer builds its own path

## Acceptance criteria

- [ ] `plan-directory` returns `$OROSHI_PLANS_DIR/<slug>`
- [ ] `plan-directory` forwards `--project`/`--branch` to `context-slug`
- [ ] `git-worktree-has-plan` delegates to `plan-directory`
- [ ] `ralph-is-running` delegates to `plan-directory`
- [ ] Prompt and statusbar still display plan progress correctly
