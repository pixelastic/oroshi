# Per-Language Scripts

Every supported language exposes the same set of ZSH functions: detect, lint,
fix, test, etc. This uniform interface lets shared dispatchers like
[`git-file-lint`](integration.md#git-file-lint) and editor integrations work
identically regardless of which language or external tool is underneath.

All these functions are **ZSH autoloaded functions**, not standalone binaries.
They are available directly in any ZSH context and can call each other without
spawning subprocesses. Non-ZSH callers (e.g. NeoVim) must invoke them through
the `bin-zsh` wrapper — see [neovim.md](neovim.md) for details.

Naming convention: `{lang}` is the short language identifier (e.g. `zsh`, `js`,
`python`, `go`, `json`, `toml`, etc).

---

## `is-{lang}`

```zsh
# Detects whether a file belongs to this language.
# Returns exit code 0 if yes, 1 otherwise.
# No stdout.
# Usage:
# $ is-zsh path/to/file.zsh    # true
# $ is-zsh path/to/file.go     # false
```

**Notes:**

Detection strategy, from most common to less common:

1. File extension (e.g. `.js`, `.py`, `.go`) — covers the vast majority of cases
2. Shebang line (e.g. `#!/usr/bin/env node`)
3. Path convention (e.g. ZSH autoload functions with no extension under specific directories)
4. Vim modeline (e.g. `# vim: ft=zsh`)

**Dependencies:**

- Used by [`git-file-lint`](integration.md#git-file-lint) to dispatch files to the correct linter
- Used by [`git-file-test`](integration.md#git-file-test) to dispatch files to the correct test runner

---

## `{lang}-lint`

```zsh
# Linter. Reports lint violations.
# Exits non-zero when violations are found.
# Directories are scanned for matching files only (e.g. zsh-lint ignores .js files).
# Usage:
# $ zsh-lint path/to/file.zsh                          # stylish output (default)
# $ zsh-lint src/foo.zsh src/bar.zsh                   # multiple files
# $ zsh-lint src/                                      # all zsh files in directory
# $ zsh-lint src/foo.zsh lib/                          # mix of files and directories
# $ zsh-lint --json path/to/file.zsh                   # unified JSON (for NeoVim, agents)
# $ zsh-lint --fix path/to/file.zsh                    # format in-place, then report remaining violations
```

**Notes:**

Two output modes:

- **Default (no flag)** — stylish format for terminal use. Violations are
  grouped by file, with an indented `line:column  level  message  rule-id` line
  per violation. When there are no violations, output is empty.
- **`--json`** — unified JSON array for machine consumers (NeoVim, agents).
  See [lint-output.md](lint-output.md) for the schema. When there are no
  violations, output is `[]`.

See [fix-lint-relationship.md](fix-lint-relationship.md) for how `{lang}-lint`
and `{lang}-fix` relate to each other.

Implementation preference ladder, simplest first:

1. Use an external linter with default options
2. Add custom options or rule exclusions
3. Combine multiple external linters (merge their JSON outputs into a single array)
4. Write custom regex-based rules using the `lint-custom-run` framework

**Dependencies:**

- Used by [`git-file-lint`](integration.md#git-file-lint) to lint changed files
- Used by [NeoVim `filetypes/{lang}.lua`](neovim.md#configurelinterlint) to populate diagnostics
- Used by [`lintstaged.config.js`](integration.md#lintstagedconfigjs) for pre-commit linting

---

## `{lang}-fix`

```zsh
# Formatter. Rewrites code to canonical style.
# Exits 0 on success (including nothing to do), 1 on error.
# Default: modifies files in-place.
# Directories are scanned for matching files only (e.g. js-fix ignores .py files).
# Usage:
# $ js-fix path/to/file.js                      # modify file in-place
# $ js-fix src/foo.js src/bar.js                # multiple files
# $ js-fix src/                                 # all js files in directory
# $ js-fix src/foo.js lib/                      # mix of files and directories
# $ js-fix path/to/file.js --stdout             # print fixed code (single file only)
# $ js-fix .conform.123.file.js --original-path src/file.js   # in-place, resolve config from src/file.js
# $ js-fix .conform.123.file.js --original-path src/file.js --stdout  # same, but to stdout
```

**Notes:**

The underlying tool varies by language — sometimes a dedicated formatter (e.g.
Prettier), sometimes the linter's own autofix mode, sometimes both chained
together. The public API is the same regardless.

Flags (only valid with a single file argument):

- **`--stdout`** — write the fixed code to stdout instead of modifying the file
    in-place.
- **`--original-path`** — the real file path on disk. Used to resolve
    language-specific configuration files and rules that depend on the file's name
    or location.

Both flags are combinable, and both require a single file argument. If either
flag is passed with multiple files or a directory, the script must exit 1.

See [fix-lint-relationship.md](fix-lint-relationship.md) for how `{lang}-fix`
and `{lang}-lint` relate to each other.

**Dependencies:**

- Used by [NeoVim `configureFormatter`](neovim.md#configureformatterconform) with `--original-path` (conform.nvim creates a temp file)
- Used by [`{lang}-lint --fix`](#lang-lint) as the formatting step before linting

---

## `{lang}-test`

```zsh
# Tester. Runs the language's test runner.
# Exits non-zero on failure.
# Usage:
# $ js-test src/__tests__/module.test.js                    # one test file
# $ js-test src/module.js                                   # source file → resolved via {lang}-test-path
# $ js-test src/                                            # all tests in directory
# $ js-test src/foo.js src/bar.js src/__tests__/baz.test.js # mix of sources, tests, directories
```

**Dependencies:**

- Uses [`{lang}-test-path`](#lang-test-path) to locate the test file when given a source file
- Used by [`git-file-test`](integration.md#git-file-test) to test changed files

---

## `{lang}-test-path`

```zsh
# Maps a source file to its corresponding test file.
# Prints the absolute test path on stdout, exits 1 if no test file exists.
# If the input is already a test file, returns it as-is.
# Usage:
# $ js-test-path src/module.js        # → src/__tests__/module.test.js
# $ python-test-path lib/helper.py    # → lib/__tests__/test_helper.py
```

**Notes:**

Source files map to test files in a sibling `__tests__/` directory. The exact naming pattern (`test_module.ext`, `module.test.ext`, `module_test.ext`) varies by language convention. The mapping is a pure string transformation — derive the test path, then check the file exists on disk.

**Dependencies:**

- Used by [`git-file-test`](integration.md#git-file-test) to resolve source files to test files
- Used by [`{lang}-test`](#lang-test) when given a source file

---

## Adding a language

1. Create [`is-{lang}`](#is-lang) — file detection function
2. Create [`{lang}-lint`](#lang-lint) — linter with `--json` and `--fix` flags
3. Create [`{lang}-fix`](#lang-fix) — formatter with `--stdout` and `--filepath` flags
4. Create [`{lang}-test`](#lang-test) — test runner
5. Create [`{lang}-test-path`](#lang-test-path) — source-to-test file mapper
