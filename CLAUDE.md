## Commands

- **Testing go:** Run `go-test <filepath>`
- **Testing js:** Run `yarn run test <filepath>`
- **Testing python:** Run `python-test <filepath>`
- **Testing zsh:** Run `zsh-test <filepath>`
- Tests files live in `__tests__` directories

- **Linting bats:** Run `bats-lint <filepath>`
- **Linting go:** Run `go-lint <filepath>`
- **Linting json:** Run `json-lint <filepath>`
- **Linting js:** Run `yarn run lint:fix <filepath>`
- **Linting python:** Run `python-lint <filepath>`
- **Linting svg:** Run `svg-lint <filepath>`
- **Linting toml:** Run `toml-lint <filepath>`
- **Linting xml:** Run `xml-lint <filepath>`
- **Linting zsh:** Run `zsh-lint <filepath>`

- **Mails**: Use `gmail-inbox-raw`, `gmail-read` and `gmail-search`
- **Confluence**: Use `confluence-read` and `confluence-search`

## Code

- DO NOT: Use the Write tool on files containing nerd font glyphs (U+E000–U+F8FF) — Write silently strips them. Use Edit only, or git checkout to restore.
- DO: For tested Node.js bin scripts in scripts/bin/, use a ZSH wrapper (no extension) + pure .js module (no shebang, exportable for vitest)

## Skills

- Never edit `~/.claude/skills/` directly.
- Resolve the symlink to find the real path inside `~/.oroshi/`
- If in a worktree, replace the `~/.oroshi/` prefix with the current worktree root (`git rev-parse --show-toplevel`)

## Plan

- Run `plan-directory` to find the PRD and issues for a given worktree
