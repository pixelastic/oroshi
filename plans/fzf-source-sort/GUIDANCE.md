## Guidance

**Goal:** Replace raw alphabetical file listing in `ctrl-p` / `ctrl-shift-p` with DFS files-first ordering (root files first, then each subdirectory's files before its own nested subdirs).

**Testing commands**
- `bats <filepath>` — run a bats test file
- `zsh-lint <filepath>` — lint a zsh file
- `bats-lint <filepath>` — lint a bats file

**Key files**
- `tools/term/zsh/config/functions/autoload/misc/sort-filepaths` — autoload function to rewrite
- `tools/term/zsh/config/functions/autoload/misc/__tests__/` — where new bats test file goes
- `scripts/bin/fzf/__lib/fzf-source-files.zsh` — FZF Helper to integrate `sort-filepaths`
- `scripts/bin/fzf/__lib/__tests__/fzf-source-files.bats` — existing colorization tests (do not break)

**Conventions**
- `sort-filepaths` accepts paths via stdin or as args; outputs sorted paths on stdout
- Tests use `bats_run_zsh "function-name args"` — no filesystem mocking, pure string input
- Prior art for test style: `tools/term/zsh/config/functions/autoload/misc/__tests__/simplify-path.bats`
- ZSH local variable assignment: `local var="$(cmd)"` + manual guard — never split `local`/assignment
- Use `[[ $flag == "1" ]]` for boolean flag tests, not `(( flag ))`
- `sort-filepaths` is autoload — do not source it explicitly in `fzf-source-files.zsh`

**Glossary**
- **FZF Helper**: a `.zsh` file in `scripts/bin/fzf/__lib/` sourced by FZF Scripts to share functions
- **fzf-source**: the Lifecycle Function that generates FZF candidates
- **fzf-dispatch**: the dispatcher called at the bottom of every FZF Script

## Discoveries
