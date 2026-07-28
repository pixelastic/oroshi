## Guidance

### Testing commands

- ZSH helpers: `bats <filepath>`
- Bats lint: `bats-lint <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- Node.js scripts: `yarn run test <filepath>`
- JS lint: `yarn run lint:fix <filepath>`

### File locations (relative to repo root)

- Skills: `tools/ai/claude/config/skills/<name>/SKILL.md`
- AI scripts: `scripts/bin/ai/<name>/`
- ZSH autoload helpers: `tools/term/zsh/config/functions/autoload/<domain>/`
- Bats tests: `tools/term/zsh/config/functions/autoload/<domain>/__tests__/`
- JSON tools: `tools/_languages/json/`
- projects.jsonc: `tools/term/zsh/config/theming/src/projects.jsonc`

### Conventions

- ZSH autoload functions use `setopt local_options err_return`
- Scripts in `scripts/bin/ai/` are on PATH
- Use `jo` for JSON output in ZSH scripts
- Use `jq` for JSON parsing in ZSH scripts
- Use `bats_mock` for mocking external commands in bats tests
- Use `bats_run_zsh "cd $dir && fn"` for running autoload functions in tests
- Node.js bin scripts: symlink (no extension) → `.js` file
- Follow existing helper naming: `<domain>-<action>` (e.g. `git-github-repo-exists`, `npm-is-published`)

### Prior art

- Thin ZSH wrapper: `tools/term/zsh/config/functions/autoload/git/github/git-github-repo-exists`
- ZSH helper with JSON parsing: `tools/term/zsh/config/functions/autoload/project/projects-build`
- AI script with JSON output: `scripts/bin/ai/sidequest/sidequest-start`
- AI script calling helpers: `scripts/bin/ai/ralph/ralph-end`
- Node.js bin script with symlink: check existing patterns in `tools/_languages/json/`
- Bats test with mocks: `tools/term/zsh/config/functions/autoload/project/__tests__/projects-build.bats`

### Domain glossary (informal, pending /glossary pass)

- `yarn-package-*`: metadata about the local package (from package.json)
- `yarn-dependency-*`: packages this project depends on (in node_modules)
- `node-module-*`: globally installed Node packages
- `npm-*`: packages on the npm registry (published artifacts)
- `git-github-*`: GitHub API operations
- `project-*`: projects.jsonc entries (terminal theming)

## Discoveries

(append-only, updated by agents after each issue)

### Issue 01 — jsonc-remove-key
- `jsonc-parser` `modify()` with `undefined` value removes the preceding comment block along with the key — not just the key/value pair
- Script placed in `scripts/bin/json/` (on PATH) not `tools/_languages/json/` (install scripts only)
- Yarn PnP: debug scripts in /tmp can't resolve repo packages; must run from within repo root
