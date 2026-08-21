# Shared Dispatchers & Configuration

These components sit above the per-language scripts and operate on sets of
files at once. Each one must learn about a new language when one is added to
the toolchain.

See [scripts.md](scripts.md) for the per-language functions these dispatchers
call.

---

## `git-file-lint`

```zsh
# Lint dispatcher for files modified or added since the last commit.
# Groups them by language, runs {lang}-lint --fix on each group.
# Exits non-zero if any violations remain after fixing.
# Deleted files are skipped automatically.
# Usage:
# $ git-file-lint                        # lint all dirty files in the working tree
```

**Notes:**

Manual lint command, called by the user in the terminal or by
[AI agent skills](agents.md) after implementation. Unlike
[`lintstaged.config.js`](#lintstagedconfigjs) which runs automatically at commit
time and blocks the commit on failure, `git-file-lint` is on-demand.

Groups modified and added files in the working tree by language using
[`is-{lang}`](scripts.md#is-lang), then runs [`{lang}-lint
--fix`](scripts.md#lang-lint) on each group. Reports violations grouped by
language.

**Dependencies:**

- Uses [`is-{lang}`](scripts.md#is-lang) to detect file language
- Uses [`{lang}-lint --fix`](scripts.md#lang-lint) to lint each group
- Used by [AI agent skills](agents.md) to lint modifications after implementation

---

## `git-file-test`

```zsh
# Test dispatcher for files modified or added since the last commit.
# Resolves them to test files, deduplicates, runs {lang}-test.
# Silently succeeds when no test files are found.
# Usage:
# $ git-file-test                        # test all dirty files in the working tree
```

**Notes:**

Iterates all modified and added files, resolves each to a test file via
[`{lang}-test-path`](scripts.md#lang-test-path), deduplicates, and runs
[`{lang}-test`](scripts.md#lang-test) on the collected test files.

**Dependencies:**

- Uses [`is-{lang}`](scripts.md#is-lang) to detect file language
- Uses [`{lang}-test-path`](scripts.md#lang-test-path) to resolve source files to test files
- Uses [`{lang}-test`](scripts.md#lang-test) to run tests
- Used by [AI agent skills](agents.md) to verify modifications after implementation

---

## RTK — Test output filtering for agents

Test runners produce verbose output (all passing tests, timing info, progress
bars, etc.) that wastes agent context. RTK filters this down to only failing
tests and relevant error messages. Two layers work together:

### `filters.toml`

```toml
# Per-language filtering rules. Each filter defines:
# - match_command: regex to match the test command
# - strip_lines_matching: array of regexes for lines to remove (passing tests, headers, etc.)
# - on_empty: message when all output is stripped (i.e. all tests passed)
# Location: tools/ai/rtk/config/filters.toml
```

### `rtk-command-rewrite`

```zsh
# Takes a ready-to-execute command and returns it prefixed with rtk if a
# matching filter exists. ZSH autoloaded commands are also prefixed with
# bin-zsh so rtk can invoke them.
# Idempotent: already-prefixed commands pass through unchanged.
# Unrecognized commands pass through unchanged.
# Called by a Claude Code hook before every command execution.
# Usage:
# $ rtk-command-rewrite "python-test tests/"                  # → rtk bin-zsh python-test tests/
```

---

## `lintstaged.config.js`

```js
// Pre-commit hook configuration.
// Maps file glob patterns to lint and test commands that run on staged files.
// Two generic yarn scripts handle all languages:
//   yarn precommit:lint {lang} — calls {lang}-lint --fix on staged files
//   yarn precommit:test {lang} — calls {lang}-test on staged files
// Example entry:
// '**/*.go': ['yarn precommit:lint go', 'yarn precommit:test go']
```

Two generic scripts in `scripts/yarn/` handle all languages:
`precommit-lint` calls `{lang}-lint --fix` on its arguments,
`precommit-test` calls `{lang}-test` on its arguments. Both take the
language identifier as their first argument.

**Dependencies:**

- Uses [`{lang}-lint`](scripts.md#lang-lint) via `precommit-lint`
- Uses [`{lang}-test`](scripts.md#lang-test) via `precommit-test`

---

## ZSH completion

File-type-aware tab completion, provided in two layers.

### Standard completion (`compdef.zsh`)

```zsh
# Registers _files -g "*.{ext}" for {lang}-lint, {lang}-test, and related commands.
# Tab only suggests files with relevant extensions.
# Usage:
# $ zsh-lint <TAB>                       # only .zsh files suggested
# $ go-test <TAB>                        # only .go files suggested
```

### CTRL-P FZF pickers (`ctrl-p.zsh`)

```zsh
# Context-aware dispatch for test commands.
# Typing a test command then pressing CTRL-P opens a dedicated fzf-{lang}-test picker.
# Usage:
# $ go-test <CTRL-P>                     # opens fzf-go-test showing only Go test files
```

---

## LS coloring

```zsh
# File extension coloring in the terminal.
# Source: tools/term/zsh/config/theming/src/filetypes.jsonc
# Extensions are grouped by category (script, config, text, etc.) with color references.
# Build: yarn colors-build-and-stage → dist/filetypes.zsh → LS_COLORS
```

---

## Adding a language

1. **`git-file-lint`** — add an `is-{lang}` check and route matched files to
   `{lang}-lint --fix`
2. **`git-file-test`** — add an `is-{lang}` check, use `{lang}-test-path` for
   resolution, call `{lang}-test`
3. **`filters.toml`** — add a filter block with `match_command` regex and
   `strip_lines_matching` patterns for the language's test runner output
4. **`rtk-command-rewrite`** — add a command match so the test command gets
   routed through RTK
5. **`lintstaged.config.js`** — add a glob pattern entry mapping the language's
   file extensions to `yarn precommit:lint {lang}` and `yarn precommit:test {lang}`
6. **`compdef.zsh`** — add `compdef` entries for the new commands; optionally
   create an `fzf-{lang}-test` picker and register it in `ctrl-p.zsh`'s
   `specialPickers` array
7. **`filetypes.jsonc`** — add file extension(s) to the appropriate group, then
   rebuild with `yarn colors-build-and-stage`
