## TLDR

New `git-status-raw` helper that normalizes `git status --porcelain` output into `filepath▮STATUS` format with no quoting.

## What to build

Create `tools/term/zsh/config/functions/autoload/git/git-status-raw`.

The function:
- Calls `git -c core.quotePath=false status --porcelain --short` to get raw porcelain output without C-style quoting
- Accepts an optional path argument (forwarded to `git -C`)
- Parses each line: extracts the two-char XY status and the filepath from position 3 onward
- Determines a single status letter per file using the same priority logic as the existing `-raw` functions: prefer the work-tree status (Y) over the index status (X); `?` maps to `A`
- Outputs `filepath▮STATUS` (one line per file)
- For renames (`R` status), git outputs `old -> new`; output `new-path▮R▮old-path` (three columns)

## Behavioral Tests

Create `tools/term/zsh/config/functions/autoload/git/__tests__/git-status-raw.bats`.

**Clean repo:**
- returns empty output for a clean repo

**Single file statuses:**
- lists untracked files as A
- lists unstaged modified files as M
- lists unstaged deleted files as D
- lists staged new files as A
- lists staged modifications as M
- lists staged deletions as D

**Spaces in paths:**
- lists file with spaces in directory name without quotes
- lists file with spaces in filename without quotes

**Multiple files:**
- lists multiple dirty files, one per line

**Path argument:**
- accepts a path argument and lists dirty files from that path
- returns empty output for a clean path argument

**Output format:**
- first column is filepath, second column is status letter, separated by the standard delimiter

## Acceptance criteria

- [ ] `git-status-raw` exists in `autoload/git/`
- [ ] Outputs `filepath▮STATUS` with no C-style quoting on paths with spaces
- [ ] Renames output `new-path▮R▮old-path`
- [ ] Accepts optional path argument
- [ ] All tests pass
- [ ] `zsh-lint` passes on the function
