## TLDR

Rewrite `plan-end` to commit to the plan's own git repo.

## What to build

Modify `tools/term/zsh/config/functions/autoload/ai/plan/plan-end`:

1. Resolve plan dir via `plan-directory`.
2. Stage all files in the plan repo: `git -C "$planDir" add -A`.
3. Commit to the plan repo: `git -C "$planDir" commit -m "<message>"`.
4. Stop claude (existing `claude-stop` call).

The commit message should follow the same pattern as today — generated via `git-commit-message` or a simple descriptive message like the content of COMMIT_HINT.md.

No longer call `git-file-add` or `git-commit-create` for the feature repo.

## Behavioral Tests

**plan-end.bats:**
- Commits all plan files to the plan's own git repo
- Plan repo has a new commit after `plan-end`
- Plan repo working tree is clean after commit

## Scaffolding Tests

- `plan-end` no longer stages or commits in the feature repo

## Acceptance criteria

- [ ] Plan files committed to plan git repo
- [ ] Plan repo is clean after `plan-end`
- [ ] Feature repo is unaffected by `plan-end`
- [ ] `claude-stop` still called
