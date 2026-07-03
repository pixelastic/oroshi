## Guidance

**Goal:** Unify `ctrl-p` and `ctrl-shift-p` — same structure, same fzf options via a shared helper. Only `SEARCH_PATH` differs between the two scripts.

**Testing:**
- `bats scripts/bin/fzf/__tests__/ctrl-p.bats`
- `bats scripts/bin/fzf/__tests__/ctrl-shift-p.bats`

**Linting:**
- `zsh-lint scripts/bin/fzf/__lib/fzf-options-files.zsh`
- `zsh-lint scripts/bin/fzf/ctrl-p`
- `zsh-lint scripts/bin/fzf/ctrl-shift-p`

**Key files:**
- `scripts/bin/fzf/__lib/` — lib directory; new helper goes here
- `scripts/bin/fzf/ctrl-p` — searches from git root (fallback `$PWD`)
- `scripts/bin/fzf/ctrl-shift-p` — searches from `$PWD`

**Conventions:**
- Lib files self-source their own dependencies (see `fzf-source-files.zsh` sourcing `fzf-colorize-path.zsh`)
- `SEARCH_PATH` is defined at top level in the script, used in both `fzf-source()` and `fzf-options()`
- Local variables: `local var="$(cmd)"` pattern (never split `local`/assignment)
- Scripts use `set -e` (shebang scripts, not autoload functions)

**Prior art:**
- `scripts/bin/fzf/__lib/fzf-source-files.zsh` — example of a self-sourcing lib
- `scripts/bin/fzf/__lib/fzf-options-base.zsh` — base options helper pattern
- `scripts/bin/fzf/__lib/fzf-options-prompt-directory.zsh` — prompt helper pattern

## Discoveries
