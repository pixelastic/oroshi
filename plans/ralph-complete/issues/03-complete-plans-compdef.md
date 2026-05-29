## TLDR

Add `ralph <TAB>` completion by wiring `plan-list-raw` into a `complete-plans` / `_plans` compdef pair.

## What to build

Create `complete-plans` (autoloaded in the `completion/` domain): consumes `plan-list-raw` output and reformats each line as `fullAbsolutePath:basename` for `_describe`.

Create `_plans` (in `completion/compdef/`): standard compdef wrapper using `_describe -V` with `completion-header`, same pattern as `_skills`.

In `compdef.zsh`, add `compdef _plans ralph` in the AI section.

No tests — correctness of `complete-plans` follows from `plan-list-raw`'s test suite.

## Acceptance criteria

- [ ] `complete-plans` is autoloaded and returns `fullAbsolutePath:basename` lines
- [ ] `_plans` compdef exists and follows the `_skills` / `_git-worktrees` pattern
- [ ] `compdef.zsh` registers `_plans` for `ralph`
- [ ] Typing `ralph <TAB>` in a repo with a `plans/` directory shows plan basenames as suggestions
- [ ] Selecting a suggestion inserts the full absolute path
- [ ] `zshlint` passes on all new files
