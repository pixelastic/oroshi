## Guidance

### Goal

Add `# zsh-lint disable-file=ruleName` file-level lint suppression to `lint-custom-run`, then update build scripts to emit this comment in generated `dist/*.zsh` files.

### Testing commands

- `bats scripts/bin/zsh/zsh-lint/__tests__/zsh-lint-custom.bats`
- `bats scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats`

### Key files

- `tools/term/zsh/config/functions/autoload/lint/lint-custom-run` — shared orchestrator for both linters; all disable logic lives here
- `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh` — sources `lint-custom-run` with `--disable-prefix zsh-lint`
- `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh` — sources `lint-custom-run` with `--disable-prefix bats-lint`
- `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint-custom.bats` — zsh-lint integration tests
- `scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats` — bats-lint integration tests
- `tools/term/zsh/config/theming/projects-build` — build script for `dist/projects.zsh`
- `tools/term/zsh/config/theming/colors-build` — build script for `dist/colors.zsh`
- `tools/term/zsh/config/theming/filetypes-build` — build script for `dist/filetypes.zsh`

### Conventions

- `lint-custom-run` is an autoload function — use `setopt local_options err_return`, not `set -e`
- Build scripts have a shebang — use `set -e`
- Tests drive `zsh-lint-custom` / `bats-lint-custom` via `bats_run_zsh` — never call `lint-custom-run` directly
- Existing disable tests use `noGroupedLocals` (zsh) and `noRunZsh` (bats) — reuse those rules
- Line-level: `# zsh-lint disable=ruleName` above the offending line
- File-level: `# zsh-lint disable-file=ruleName` anywhere in the file (conventionally top)

### Prior art

- Existing line-level disable tests in `zsh-lint-custom.bats` (tests named "disable comment suppresses…")
- Existing line-level disable tests in `bats-lint-custom.bats` (tests named "bats-lint disable=X…")
- File-level scan should piggyback on the existing `fileContentCache` block in `lint-custom-run`

## Discoveries

_Append findings here after each issue completes._
