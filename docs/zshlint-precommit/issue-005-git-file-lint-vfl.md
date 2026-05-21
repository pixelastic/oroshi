## PRD

[zshlint-precommit/PRD.md](./PRD.md)

## What to build

New autoloaded function `git/file/git-file-lint`, aliased as `vfl`. Mirrors the structure of `git-file-test`: reads dirty files from `git-file-list-dirty-raw`, skips deleted files, calls `is-zsh` on each path, collects ZSH files, and runs `zshlint` on all of them. If the working tree is clean or no dirty ZSH files are found, exits 0 silently.

The raw JSON output from `zshlint` is formatted inline (via `jq`) into one human-readable line per violation:

```
file:line:col: code: message
```

No level field in the output. The rule code is always included.

Add `alias vfl='git-file-lint'` alongside the existing `vft` alias.

## Acceptance criteria

- [ ] `vfl` with a dirty `.zsh` file containing violations prints `file:line:col: code: message` lines and exits 1
- [ ] `vfl` with a dirty `.zsh` file with no violations prints nothing and exits 0
- [ ] `vfl` with only dirty non-ZSH files prints nothing and exits 0
- [ ] `vfl` with a clean working tree exits 0
- [ ] `vfl` skips deleted ZSH files without error
- [ ] Output contains the rule code (e.g. `noGroupedLocals`, `SC2155`)
- [ ] Output does not contain a level field (`error`/`warning`)
- [ ] `alias vfl='git-file-lint'` exists in `aliases/git/file.zsh`
- [ ] Bats test file exists at `git/file/__tests__/git-file-lint.bats` covering all cases above

## Blocked by

- issue-003 (`is-zsh` must exist)
