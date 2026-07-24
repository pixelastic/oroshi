## Guidance

### Autoload base path
All autoload functions live under `tools/term/zsh/config/functions/autoload/` (relative to repo root).

### Testing commands
- Run bats tests: `bats <filepath>`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`

### Conventions
- Autoload functions use `setopt local_options err_return`, not `set -e`
- Autoload functions use `return`, not `exit`
- Autoload functions have no shebang line
- Test files live in `__tests__/` directories colocated with their source
- `*-test-path` contract: echo test path on stdout + return 0, or silent return 1

### Prior art
- `scripts/bin/term/bats/bats-test-path` — reference for test-path interface (will be migrated in issue 01)
- `scripts/bin/python/python-test-path` — same pattern for Python
- `scripts/bin/term/bats/__tests__/bats-test-path.bats` — reference for testing a `*-test-path` function
- `autoload/term/js/is-js` — reference for `is-*` detector interface
- `autoload/git/file/git-file-edit` — the file to modify in issue 04

### File naming
- `_languages/` uses single underscore prefix (mirrors `tools/_languages/`)
- Language subdirectory names: `javascript/` (not `js/`), `python/`, `bats/`, `zsh/`

## Discoveries

(append-only, updated after each issue)
