## Guidance

- All functions live in `tools/term/zsh/config/functions/autoload/system/process/`
- Tests live in `tools/term/zsh/config/functions/autoload/system/process/__tests__/`
- Use `/zsh-writer` for function implementations
- Use `/tdd` for test-driven development
- Run tests: `bats <filepath>`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`
- Boilerplate: `setopt local_options err_return`, `zparseopts` for `--reply`
- Reference for `--reply` pattern: `tools/term/zsh/config/functions/autoload/system/sys-cpu`
- Reference for raw/display pattern: `tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-list-raw` and `git-worktree-list`
- Reference for bats integration tests: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-list-raw.bats`
- Reference for bats mocked display tests: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-list.bats`
- Separator convention: `▮` (U+25AE)
- Color keys: `executable` for process name, `number` for PID
- Theme source: `tools/term/zsh/config/theming/src/colors.jsonc`
- Theme dist: `tools/term/zsh/config/theming/dist/colors.zsh`
- Rebuild theme: run `colors-build`

## Discoveries

### Issue 03 — process-parent
- /proc/PID/stat comm field (field 2) can contain spaces; must strip past last `)` before splitting fields to get PPID
