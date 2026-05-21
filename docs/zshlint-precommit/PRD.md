## Problem Statement

ZSH scripts and autoloaded ZSH functions can accumulate lint errors silently — shellcheck violations and custom rule violations are only caught when manually running `zshlint`. Nothing enforces lint hygiene at commit time, meaning bad patterns (incorrect `local` usage, grouped locals, manual arg parsing, etc.) land in the repo undetected.

Additionally, there is no quick way to lint all modified files in the working tree during development, the way `vft` already does for bats tests.

## Solution

Add `zshlint` to the pre-commit hook so any staged ZSH file (script or autoloaded function) is linted before the commit lands. Block the commit on any violation. Complement with a `vfl` alias that lints all dirty ZSH files in the working tree for interactive use.

Move shellcheck configuration out of the linter script and into a tracked config file so rules can be managed declaratively. Promote all custom lint rule levels to `error` so they participate in the blocking logic.

Reorganise the install domain so shellcheck and shfmt live alongside other terminal tooling (kitty, zsh) rather than under the generic `_languages` domain.

## User Stories

1. As a developer, I want the pre-commit hook to run `zshlint` on every staged ZSH file, so that lint violations are caught before they enter the repo.
2. As a developer, I want the pre-commit hook to block the commit when any `zshlint` violation is found, so that the repo stays lint-clean over time.
3. As a developer, I want `zshlint` to run on ZSH scripts identified by a `.zsh` extension, so that explicitly typed files are always checked.
4. As a developer, I want `zshlint` to run on autoloaded ZSH functions (files without extension inside the `functions/autoload/` tree), so that the function library stays lint-clean.
5. As a developer, I want `zshlint` to run on executable scripts without extension whose shebang is `#!/usr/bin/env zsh`, so that all ZSH scripts are covered regardless of extension.
6. As a developer, I want directories and non-ZSH files (Ruby, Bash, etc.) to be silently skipped at pre-commit, so that non-ZSH changes are never blocked by the ZSH linter.
7. As a developer, I want to type `vfl` to lint all dirty ZSH files in the working tree, mirroring what `vft` does for bats tests.
8. As a developer, I want `vfl` output to show `file:line:col: code: message` per violation, so I can read and act on violations without parsing JSON.
9. As a developer, I want the rule code included in `vfl` output (e.g. `noGroupedLocals`, `SC2155`), so I know exactly which rule to disable if it is a false positive.
10. As a developer, I want shellcheck's excluded rules to live in a tracked config file rather than hardcoded in the linter script, so the list is easy to review and modify.
11. As a developer, I want shellcheck to use the tracked config file automatically when `zshlint-shellcheck` runs, so I never need to pass flags manually.
12. As a developer, I want all custom lint rules to be classified as `error` level, so every violation blocks the commit by default.
13. As a developer, I want to downgrade a custom rule to `warning` if it produces too many false positives, so it stops blocking without having to delete the rule.
14. As a developer, I want shellcheck and shfmt install scripts to live alongside kitty and zsh in the terminal install domain, so the domain structure reflects how these tools are actually used.

## Implementation Decisions

### ZSH file detection — `is-zsh`

A new deep module encapsulates ZSH file detection. It takes a single file path and exits 0 if the file is a ZSH file, 1 otherwise. Detection rules applied in order:

1. Not a regular file (directory, symlink, etc.) → not ZSH.
2. File has a `.zsh` extension → ZSH.
3. File path contains `functions/autoload/` and has no extension → ZSH.
4. File has no extension and its first line is exactly `#!/usr/bin/env zsh` → ZSH.
5. Otherwise → not ZSH.

The function lives in the `term/zsh` subdomain of autoloaded functions (alongside `term/bats`), reflecting that it is a terminal-tooling utility rather than a git or language utility. No path overrides or environment variables are needed; the autoload path substring match works correctly against real paths including temporary test directories.

### Pre-commit lint runner — `lint-zsh`

A new yarn script (sibling of `test-bats`) receives staged file paths as arguments from lint-staged. It iterates the arguments, calls `is-zsh` on each, collects those that pass, then calls `zshlint` once with all ZSH file paths. The exit code of `zshlint` determines whether the commit is blocked — no JSON parsing is performed. If no ZSH files are found among the staged files, the script exits 0 silently.

### lint-staged wiring

The existing lint-staged entry for `{scripts/bin,config/term/zsh}/**/*` is converted from a single command to an array, adding `lint-zsh` alongside `test-bats`. Both run for the same set of staged files.

### Interactive lint alias — `git-file-lint` / `vfl`

A new autoloaded function in the `git/file` subdomain mirrors the structure of `git-file-test`. It reads the dirty file list from `git-file-list-dirty-raw`, skips deleted files, calls `is-zsh` on each path, collects ZSH files, and runs `zshlint` on all of them. The raw JSON output from `zshlint` is piped through an inline `jq` formatter that produces one `file:line:col: code: message` line per violation. The alias `vfl` maps to this function.

### Custom rule level promotion

All six custom lint rules currently emitting `warning` or `style` level are changed to emit `error`. The existing `zshlint` exit logic (exit 1 on any non-empty JSON array) already covers errors; no changes needed to the orchestrator.

The semantic for levels after this change:
- `error` — blocks pre-commit, shown by `vfl`.
- `warning` — does not block pre-commit (zshlint still exits 1 on warnings, but this is the downgrade escape hatch — a rule moved to warning is intentionally silenced).

Wait — actually per the design session: zshlint exits 1 on ANY violation regardless of level. So `warning` violations also block. The downgrade path (warning = skipped) would require filtering in `lint-zsh`. After discussion this was simplified to: **all violations block, disable a rule entirely if it is too noisy**. Both `error` and `warning` block the pre-commit.

### shellcheck configuration — `shellcheckrc.config`

A new file in `config/term/shellcheck/` replaces the hardcoded `excludedRules` array in `zshlint-shellcheck`. The file uses shellcheck's `disable=` directive to suppress the rules that are not applicable to ZSH. `external-sources=true` is also set. `zshlint-shellcheck` passes this file to shellcheck via `--rcfile`, resolving the path using `$OROSHI_ROOT`.

The `_languages/shell/` install domain is removed. `shellcheck` and `shfmt` install scripts move to `scripts/install/term/`, as siblings of `kitty` and `zsh`.

## Testing Decisions

Good tests verify external behaviour only — they call the public interface with realistic inputs and assert on outputs/exit codes, without asserting on internal implementation details.

### `is-zsh`

Prior art: `scripts/bin/term/bats/__tests__/bats-test-path.bats` — tests a path-inspection utility with a fixed set of representative paths.

Test cases:
- A `.zsh` file → exit 0.
- A file inside `functions/autoload/` with no extension → exit 0.
- A file with no extension whose first line is `#!/usr/bin/env zsh` → exit 0.
- A file with no extension whose first line is `#!/usr/bin/env ruby` → exit 1.
- A file with no extension and no shebang → exit 1.
- A directory path (no extension) → exit 1.
- A `.bats` file inside `functions/autoload/` → exit 1.

### `git-file-lint`

Prior art: `config/term/zsh/functions/autoload/git/file/__tests__/git-file-list-dirty-raw.bats` — sets up a real temporary git repo, stages/modifies files, runs the function, asserts on stdout.

Test cases:
- Working tree contains a dirty `.zsh` file with a violation → output contains the formatted violation line, exit 1.
- Working tree contains a dirty `.zsh` file with no violation → no output, exit 0.
- Working tree contains only dirty non-ZSH files → no output, exit 0.
- Working tree is clean → exit 0 immediately.
- Working tree contains a deleted ZSH file → deleted file is skipped, no error.

## Out of Scope

- Adding a per-rule severity override mechanism to shellcheck (not supported by shellcheck).
- Formatting `lint-zsh` pre-commit output (raw zshlint output is acceptable at commit time; `vfl` handles human-readable output).
- Writing tests for `lint-zsh` (pre-commit glue script, not a deep module).
- Reorganising the broader `_languages/` install domain beyond removing `shell/`.
- Adding a `shell` config domain alongside `bats`, `kitty`, `zsh` in `config/term/` (beyond the `shellcheck/` subdirectory added here).
- Supporting `#!/bin/zsh` shebang (not used in this repo).

## Further Notes

The `vfl` / `git-file-lint` formatter outputs JSON-derived lines intended for human reading only. If machine-parseable output is needed in the future (e.g. for editor integration), `zshlint` already provides JSON via its native interface.

The decision to block on both `warning` and `error` (rather than `error` only) was reached after confirming that shellcheck does not support per-rule severity promotion. The escape hatch for noisy rules is `disable=` in `shellcheckrc.config` (for shellcheck rules) or changing the rule's emitted level to `warning` in the rule source (for custom rules) — with the understanding that warnings still block until a future filtering mechanism is added.
