# Shared Dispatchers & Configuration

These components sit above the per-language scripts and operate on sets of
files at once. Each one must learn about a new language when one is added to
the toolchain.

See [scripts.md](scripts.md) for the per-language functions these dispatchers
call.

---

## `git-file-lint`

```zsh
# Lint dispatcher for dirty files.
# Groups dirty files by language, runs {lang}-lint --fix on each group.
# Exits non-zero if any violations remain after fixing.
# Deleted files are skipped automatically.
# Usage:
# $ git-file-lint                        # lint all dirty files in the working tree
```

**Notes:**

Uses `git-file-list-dirty-raw` to obtain the dirty file list. Groups files by
language using [`is-{lang}`](scripts.md#is-lang), then runs
[`{lang}-lint --fix`](scripts.md#lang-lint) on each group. Reports violations
grouped by language.

**Adding a language:** add an `is-{lang}` check and route matched files to
`{lang}-lint --fix`.

**Dependencies:**

- Uses [`is-{lang}`](scripts.md#is-lang) to detect file language
- Uses [`{lang}-lint --fix`](scripts.md#lang-lint) to lint each group
- Used by [AI agent skills](agents.md) to lint modifications after implementation

---

## `git-file-test`

```zsh
# Test dispatcher for dirty files.
# Resolves dirty files to test files, deduplicates, runs {lang}-test.
# Silently succeeds when no test files are found.
# Usage:
# $ git-file-test                        # test all dirty files in the working tree
```

**Notes:**

Iterates all dirty files, resolves each to a test file via
[`{lang}-test-path`](scripts.md#lang-test-path), deduplicates, and runs
[`{lang}-test`](scripts.md#lang-test) on the collected test files.

**Adding a language:** add an `is-{lang}` check, use `{lang}-test-path` for
resolution, call `{lang}-test`.

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

### `rtk-command-rewrite`

```zsh
# Decides whether to route a command through RTK.
# Idempotent: already-prefixed commands pass through unchanged.
# Unrecognized commands pass through unchanged.
# Usage:
# $ rtk-command-rewrite "go test ./..."              # → rtk bin-zsh go test ./...
# $ rtk-command-rewrite "rtk bin-zsh go test ./..."  # → unchanged
# $ rtk-command-rewrite "echo hello"                 # → unchanged
```

### `filters.toml`

```toml
# Per-language filtering rules. Each filter defines:
# - match_command: regex to match the test command
# - strip_lines_matching: array of regexes for lines to remove (passing tests, headers, etc.)
# - on_empty: message when all output is stripped (i.e. all tests passed)
# Location: tools/ai/rtk/config/filters.toml
```

**Adding a language:**

1. Add a filter block in `filters.toml` with `match_command` regex and
   `strip_lines_matching` patterns specific to the language's test runner output
2. Add a command match in `rtk-command-rewrite` so the test command gets routed
   through RTK

---

## `lintstaged.config.js`

```js
// Pre-commit hook configuration.
// Maps file glob patterns to lint and test commands that run on staged files.
// Yarn script wrappers in scripts/yarn/ delegate to per-language tools.
// Lint scripts call {lang}-lint --fix so files are formatted before commit.
// Example entry:
// '**/*.go': ['yarn lint:go', 'yarn test:go']
```

**Adding a language:**

1. Create yarn wrapper scripts in `scripts/yarn/` that call the per-language tools
2. Register those scripts in `package.json` (e.g. `lint:go`, `test:go`)
3. Add a glob pattern entry in `lintstaged.config.js` mapping the language's
   file extensions to the new yarn scripts

**Dependencies:**

- Uses [`{lang}-lint`](scripts.md#lang-lint) via yarn script wrappers
- Uses [`{lang}-test`](scripts.md#lang-test) via yarn script wrappers

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

**Adding a language:** add `compdef` entries for the new commands. Optionally
create an `fzf-{lang}-test` picker and register it in `ctrl-p.zsh`'s
`specialPickers` array.

---

## LS coloring

```zsh
# File extension coloring in the terminal.
# Source: tools/term/zsh/config/theming/src/filetypes.jsonc
# Extensions are grouped by category (script, config, text, etc.) with color references.
# Build: yarn colors-build-and-stage → dist/filetypes.zsh → LS_COLORS
```

**Adding a language:** add the file extension(s) to the appropriate group in
`filetypes.jsonc`, then rebuild with `yarn colors-build-and-stage`.
