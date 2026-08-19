## Commands

- **Testing zsh:** Run `bats <filepath>`
- **Testing js:** Run `yarn run test <filepath>`
- **Testing python:** Run `python-test <filepath>`
- **Testing go:** Run `go-test <filepath>`
- Tests files live in `__tests__` directories

- **Linting zsh:** Run `zsh-lint <filepath>`
- **Linting bats:** Run `bats-lint <filepath>`
- **Linting js:** Run `yarn run lint:fix <filepath>`
- **Linting python:** Run `python-lint <filepath>`
- **Linting go:** Run `go-lint <filepath>`

## Code

- DO NOT: Use the Write tool on files containing nerd font glyphs (U+E000–U+F8FF) — Write silently strips them. Use Edit only, or git checkout to restore.
- DO: Edit skill files under the worktree path, never via ~/.claude/skills/ symlinks (which point to main)
- DO: For tested Node.js bin scripts in scripts/bin/, use a ZSH wrapper (no extension) + pure .js module (no shebang, exportable for vitest)
