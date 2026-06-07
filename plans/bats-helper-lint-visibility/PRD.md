## Problem Statement

Two BATS helper files (`helper` and `rules-helper`) have no `.bats` extension and carry a `ft=bash` vim modeline. This makes them invisible to every lint context: NeoVim lints them as bash, `git-file-lint` routes only `*.bats` glob matches to bats-lint, and lint-staged uses the same `*.bats` glob. Renaming to `.bats` is blocked because `bats_load_library 'helper'` resolves by exact filename — the extension would break all test files.

## Solution

Introduce an `is-bats` predicate function that detects bats files by extension **or** by a `ft=bats` modeline on line 1 of extensionless files. Wire `git-file-lint` and the `lint-bats` yarn script to use it instead of the raw glob. Update lint-staged to also pass the helper paths to `lint:bats`. Fix the modeline in both helper files from `ft=bash` to `ft=bats`. Add per-line `noRunZsh` disable comments where the helpers legitimately use `run zsh` as their underlying implementation.

## User Stories

1. As a developer, I want NeoVim to apply bats syntax and diagnostics to `helper` and `rules-helper`, so that I get correct highlighting and inline errors while editing them.
2. As a developer, I want `git-file-lint` to route `helper` and `rules-helper` to bats-lint when they are dirty, so that pre-push linting catches regressions in helper code.
3. As a developer, I want lint-staged to run `lint:bats` on `helper` and `rules-helper` at commit time, so that the pre-commit hook enforces bats quality on helper files.
4. As a developer, I want the `is-bats` function to be the single source of truth for bats-file detection, so that I only need to update one place if detection logic ever changes.
5. As a developer, I want `is-bats` to return exit 0 for `*.bats` files, so that existing bats test files continue to be detected correctly.
6. As a developer, I want `is-bats` to return exit 0 for extensionless files with a `ft=bats` modeline on line 1, so that BATS library helpers without extensions are detected correctly.
7. As a developer, I want `is-bats` to return exit 1 for symlinks and directories, so that the function does not follow links or traverse directories.
8. As a developer, I want `is-bats` to return exit 1 for files with any other extension, so that non-bats files are never mis-classified.
9. As a developer, I want the `noRunZsh` bats-lint violations in `helper` and `rules-helper` suppressed inline, so that linting these files does not produce false positives for the legitimate `run zsh` calls that underpin their implementation.
10. As a developer, I want the `lint-bats` yarn script to use `is-bats` for filtering, so that it accepts both extensioned and extensionless bats files when called directly.
11. As an agent reading git-file-lint tests, I want a regression test for the extensionless bats helper path, so that future changes to routing logic cannot silently drop helper files.

## Implementation Decisions

### `is-bats` predicate

- Lives in the `term/bats` autoload subdomain (not `term/zsh`), consistent with the bats function grouping.
- Detection order: symlink/non-file → reject; `*.bats` extension → accept; any other extension → reject; no extension + `ft=bats` on line 1 → accept; else → reject.
- Only line 1 is checked for the modeline (consistent with how `is-zsh` checks only line 1 for the shebang). Vim modeline position is a controlled convention for files we own.
- Modeled structurally after `is-zsh` (return-early pattern, `setopt local_options err_return`).

### Modeline change

- Both helper files change `# vim: set ft=bash:` → `# vim: set ft=bats:` on line 1.
- This is what enables `is-bats` detection and also fixes NeoVim syntax highlighting.

### `noRunZsh` suppression

- Both helpers use `run zsh -c "..."` as the underlying implementation of `bats_run_zsh` and `run_rule` — these are legitimate, not violations of the rule's intent.
- Per-line `# bats-lint disable=noRunZsh` comments are added on the line above each `run zsh` occurrence (4 in `helper`, 1 in `rules-helper`).
- The existing `lint-custom-run` inline disable mechanism handles this — no new infrastructure needed.

### `git-file-lint` update

- The raw `*.bats` glob check in the routing loop is replaced with a call to `is-bats`.
- `is-bats` receives the full absolute path (same as the existing `is-zsh` call pattern).

### `lint-bats` yarn script update

- The inner filter that drops non-`*.bats` files is replaced with a call to `is-bats`.
- Since `is-bats` is an autoloaded function and the script is invoked by zsh (which sources `.zshenv` and sets up `fpath`), the call works without additional bootstrapping.

### `lintstaged.config.js` update

- The `'**/*.bats'` entry is replaced with `'{**/*.bats,tools/term/bats/config/*}'`.
- The broader glob passes all matching staged files to `lint:bats`; `is-bats` inside `lint-bats` acts as the authoritative filter, so non-bats files in `tools/term/bats/config/` (if any were ever added) would be silently skipped.
- The existing `'tools/**/*': ['yarn run lint:zsh']` entry also matches the helper paths — this is acceptable because `lint:zsh` is a no-op on non-zsh files.

## Testing Decisions

Good tests assert external behavior through the public interface, not implementation details. For `is-bats`, the public interface is: filepath in, exit code out.

### `is-bats` unit tests

- Full coverage of the detection matrix: `.bats` extension, other extension, no extension + `ft=bats` modeline, no extension + wrong modeline, no extension + no modeline, symlink, directory.
- Prior art: `is-zsh.bats` — same shape of tests (create temp file, call function via `bats_run_zsh`, assert status).

### `git-file-lint` regression test

- One new test: creates an extensionless file with `ft=bats` modeline, marks it dirty, verifies that `git-file-lint` routes it to bats-lint.
- `is-bats` is mocked via `bats_mock` so the test isolates routing logic from detection logic.
- Prior art: existing `git-file-lint.bats` tests for the `*.bats` routing case.

### Not tested

- `lintstaged.config.js` — config files are the artifact, per project convention.
- `lint-bats` yarn script — the glob-to-`is-bats` swap is a one-line change with no branching logic worth unit-testing independently.

## Out of Scope

- File-level `# bats-lint file-disable=<rule>` mechanism — not needed here; per-line disables are sufficient.
- Detecting bats helpers by directory convention (e.g., `*/bats/config/*`) — `is-bats` stays content-based, not path-based.
- Updating NeoVim configuration — the modeline change alone fixes NeoVim behavior, no ftplugin changes required.
- Any changes to the bats-lint rule set itself.

## Further Notes

- The `is-zsh` function is the direct model for `is-bats`. Reading it before implementing `is-bats` is recommended.
- The `lint-custom-run` inline disable mechanism (checking the line above a violation for `# bats-lint disable=<code>`) is already in place — no changes to it are needed.
