## Guidance

### What this plan does

Adds `git-worktree-rename` (alias `vwmv`) — a command that renames a linked
worktree's branch, directory, and plans artifacts atomically. As a
prerequisite, migrates `git-branch-rename` from `scripts/bin/` to the
autoloaded function tree.

### Vocabulary

- **Linked worktree**: a git worktree that is not the Git Repo Main (checked
  via `git-directory-is-worktree`)
- **Git Repo Main**: the primary checkout, returned by `git-worktree-main`
- **Worktree directory**: `$OROSHI_WORKTREES_DIR/<repoName>--<branchSlug>`
- **Branch slug**: filesystem-safe form of a branch name (`/` → `_`, `.` → `-`),
  computed by `git-branch-slug`
- **Plans directory**: `plans/<branchSlug>/` at the Git Repo Main root

### File locations (relative to repo root)

- Autoloaded worktree functions: `tools/term/zsh/config/functions/autoload/git/worktree/`
- Autoloaded branch functions: `tools/term/zsh/config/functions/autoload/git/branch/`
- Worktree BATS tests: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/`
- Branch BATS tests: `tools/term/zsh/config/functions/autoload/git/branch/__tests__/`
- Worktree aliases: `tools/term/zsh/config/aliases/git/worktree.zsh`
- Compdef wiring: `tools/term/zsh/config/completion/compdef.zsh`
- Bin scripts (source of migration): `scripts/bin/git/branch/`

### Testing commands

- Run BATS tests: `bats <filepath>`
- Lint ZSH function: `zsh-lint <filepath>`
- Lint BATS file: `bats-lint <filepath>`

### Key prior art

- `git-worktree-delete` — closest behavioral model: upfront blocking check,
  auto-cd side-effect, plans artifact cleanup. Read before implementing issue 02.
- `git-worktree-create` — repo name resolution pattern (GitHub project name
  with folder-name fallback). Copy the same logic for the new directory path.
- `git-worktree-delete.bats` — prior art for testing cd side-effects (subshell
  + `echo "$PWD"` pattern), blocking conditions, and plans artifact behavior.
- `git-branch-current.bats` — prior art for branch function BATS structure.

### ZSH conventions

- `setopt local_options err_return` at top of every autoloaded function
- `local var="$(cmd)"` + manual guard (never `local var; var=$(cmd)`)
- `[[ $isXxx == "1" ]]` for flag boolean tests, never `(( isXxx ))`
- `if/then/fi` for 2+ instructions; `&&` only for single-action one-liners
- Fix pre-existing `zsh-lint` violations in any file you touch

### BATS conventions

- All variables (including `CURRENT`) go inside `setup()`, not at file top level
- Use `bats_run_zsh` to invoke functions (sources the function without .zshenv PATH rebuild)
- Use `bats_mock` to stub external commands
- Use `bats_git_dir` / `bats_git_worktree` helpers to set up git fixtures
- cd side-effect tests: write a small inline script to `$BATS_TMP_DIR`, run it
  with `bats_run_zsh`, assert on `${lines[-1]}`

### OROSHI_ROOT / PATH / FPATH

No explicit handling needed in `git-worktree-rename`. The `oroshi-chpwd` hook
in `prompt/index.zsh` fires automatically on every `cd` and re-derives
`OROSHI_ROOT`, `ZSH_CONFIG_PATH`, PATH, and FPATH from the new `$PWD`.

## Discoveries

_Append findings here after each issue. Format: `### Issue XX — short title` + bullet points._
