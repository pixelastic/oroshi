## Guidance

### Testing

- ZSH tests: `bats <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`
- Tests live in `__tests__/` sibling directories

### Key directories

- Autoload functions: `tools/term/zsh/config/functions/autoload/`
- Git helpers: `tools/term/zsh/config/functions/autoload/git/`
- Context/project domain (pre-reorg): `tools/term/zsh/config/functions/autoload/project/`
- Yarn helpers: `tools/term/zsh/config/functions/autoload/yarn/`
- Prompt: `tools/term/zsh/config/prompt/`

### Conventions

- ZSH autoload functions: no shebang, use `setopt local_options err_return`
- `--repo` pattern: `zparseopts -E -D -repo:=flagRepo`, extract with `${flagRepo[2]}`, default to current repo
- `--reply` pattern: `zparseopts -E -D -reply=flagReply`, write to `$REPLY` when set, echo otherwise
- `local var="$(cmd)"` + manual guard — never split local/assignment
- `[[ $flag == "1" ]]` for boolean tests, not `(( flag ))`
- `if/then/fi` for 2+ instructions, `&&` only for single-action one-liners
- Use `bats_run_zsh "cd $dir && fn"` in tests — never `cd` before
- Use `bats_mock` for stubbing collaborators in tests
- Use `bats_disable_worktree_aware` to avoid over-mocking in worktree-aware tests

### Prior art

- `--repo` pattern: see `git-file-add` in `git/file/`
- `--reply` pattern: see `sys-fans` in `system/`
- `context-*` functions: see `context-badge`, `context-root` for how they resolve project + worktree
- Dependency update chain: see `git-branch-pull` for the capture-commit-then-update pattern
- `fork` usage: see `git-dependencies-update-node` for background execution with lockfile
- Worktree directory naming: see `git-worktree-create` for the `repoName--branchSlug` pattern

### Glossaries

- `context/GLOSSARY.md` (currently `project/GLOSSARY.md`) — Context, Project, Context Root, Context Badge definitions
- `git/worktree/GLOSSARY.md` — Worktree, Git Repo Main, Branch Slug, Worktree Directory Name, Repo Name definitions

## Discoveries
