## Guidance

- **Language**: all scripts are ZSH. Use `setopt local_options err_return` in autoloaded functions.
- **Testing**: run `bats <filepath>` for ZSH scripts.
- **Linting**: run `zsh-lint <filepath>` for ZSH scripts.
- **BATS helper**: shared test helper at `tools/term/bats/config/helper`. Has `bats_git_worktree` for creating test worktrees. Follow the `MOCK_OROSHI_WORKTREES_DIR` pattern for `MOCK_OROSHI_PLANS_DIR`.
- **Env var pattern**: `export VAR="${MOCK_VAR:-$HOME/default/path}"` in `tools/term/zsh/config/zshenv-host.zsh`.
- **Delimiter**: use `▮` (U+25AE) for field-separated output in raw functions.
- **context-slug**: at `tools/term/zsh/config/functions/autoload/context/context-slug`. Tests at `__tests__/context-slug.bats`.
- **plan functions**: at `tools/term/zsh/config/functions/autoload/ai/plan/`. `plan-list-raw` is at `tools/term/zsh/config/functions/autoload/plan/plan-list-raw` (different parent dir).
- **git-commit-create**: at `tools/term/zsh/config/functions/autoload/git/commit/git-commit-create`. Single bottleneck for all commit aliases.
- **git-file-edit**: at `tools/term/zsh/config/functions/autoload/git/file/git-file-edit`. Already skips `plans/*/state.json` and `plans/*/scaffold/*`.
- **Worktree glossary**: terms defined in `tools/term/zsh/config/functions/autoload/git/worktree/__docs/GLOSSARY.md`. Use "Plans Store" for `$OROSHI_PLANS_DIR`, "Plan Repo" for the git repo inside each plan dir.
- **Bootstrap**: this plan itself lives locally with a symlink to `$OROSHI_PLANS_DIR/oroshi--plan-storage/` (created by issue 02). Both old and new code resolve to the same files during transition.
- **No fallback**: new code reads external only. Old worktrees use old code reading local plans. No dual-path logic.

## Discoveries
