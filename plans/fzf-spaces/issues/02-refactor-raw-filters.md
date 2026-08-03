## TLDR

Refactor the three `-raw` functions to be thin filters over `git-status-raw`, outputting `filepath▮STATUS` instead of `STATUS:filepath`.

## What to build

Refactor these three functions to call `git-status-raw` instead of `git status --porcelain` directly:

- `tools/term/zsh/config/functions/autoload/git/file/git-file-list-dirty-raw`
- `tools/term/zsh/config/functions/autoload/git/file/git-file-list-dirty-stageable-raw`
- `tools/term/zsh/config/functions/autoload/git/file/git-file-list-staged-raw`

Each becomes a filter: call `git-status-raw`, loop over lines, split on `▮`, apply its specific filter logic, and re-emit `filepath▮STATUS`.

**`dirty-raw`** — keeps everything (both staged and unstaged). Keeps its path argument support (passes it to `git-status-raw`). Preserves rename handling (re-emits the three-column format from `git-status-raw`).

**`dirty-stageable-raw`** — keeps only files with a non-blank work-tree status. Needs to re-parse the porcelain XY columns to filter correctly. Since `git-status-raw` already resolves to a single status, the filter logic is: call `git-status-raw`, but the stageable filter needs the original XY to know if the work-tree column is non-blank. Two options: (a) have `git-status-raw` expose both columns, or (b) keep the stageable filter's own logic. Since `git-status-raw` resolves to a single letter, `dirty-stageable-raw` should call `git-status-raw` and simply pass through all lines — `git-status-raw` already prefers the work-tree status. The difference is: `dirty-stageable-raw` skips files that are ONLY staged (work-tree clean). It needs the original XY. So it should call `git-status-raw` for the unquoted path benefit but still needs to know if the file has unstaged changes. Reconsider during implementation: it may be simpler to call `git -c core.quotePath=false status --porcelain --short` directly and keep its own XY parsing, while still outputting `filepath▮STATUS`.

**`staged-raw`** — keeps only files with a non-blank index status. Same consideration as stageable-raw: needs the original X column.

## Scaffolding Tests

**`git-file-list-dirty-raw.bats`** (update existing):
- all assertions change from `STATUS:filepath` to `filepath▮STATUS`
- add test: file with spaces in path outputs without quotes

**`git-file-list-dirty-stageable-raw.bats`** (new):
- skips files that are only staged (work-tree clean)
- includes untracked files as A
- includes unstaged modified files as M
- file with spaces outputs without quotes

**`git-file-list-staged-raw.bats`** (new):
- skips untracked and unstaged-only files
- includes staged new files as A
- includes staged modifications as M
- file with spaces outputs without quotes

## Acceptance criteria

- [ ] All three `-raw` functions output `filepath▮STATUS`
- [ ] No function calls `git status --porcelain` directly (all go through `git-status-raw` or use `core.quotePath=false`)
- [ ] Paths with spaces have no C-style quotes in output
- [ ] Existing `dirty-raw` tests pass (updated format)
- [ ] New `dirty-stageable-raw` and `staged-raw` tests pass
- [ ] `zsh-lint` passes on all three functions
