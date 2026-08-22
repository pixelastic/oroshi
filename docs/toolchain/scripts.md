# Per-Language Scripts

Every supported language exposes the same set of ZSH functions: detect, lint,
fix, test, etc. This uniform interface lets shared dispatchers like
[`git-file-lint`](integration.md#git-file-lint) and editor integrations work
identically regardless of which language or external tool is underneath.

All these functions are **ZSH autoloaded functions**, not standalone binaries.
They are available directly in any ZSH context and can call each other without
spawning subprocesses. Non-ZSH callers (e.g. NeoVim) must invoke them through
[`bin-zsh`](utilities.md#bin-zsh).

They live in `tools/term/zsh/config/functions/autoload/_languages/{lang}/`,
one directory per language.

Naming convention: `{lang}` is the short language identifier (e.g. `zsh`, `js`,
`python`, `go`, `json`, `toml`, etc).

---

## External tool installation

Each language's external tools (linters, formatters, test runners) must be
installable from the repository for reproducibility. Two methods are available,
in order of preference.

### Preferred — `tools/_languages/{lang}/{tool-name}/`

Each tool gets a directory under the language's `tools/_languages/{lang}/`
folder with:

- **`install`** *(required)* — idempotent script that installs the tool
  globally on the machine. Run once per setup.
- **`config/`** *(optional)* — configuration files for the tool, deployed by
  `deploy` and referenced at runtime via `$OROSHI_ROOT`
- **`deploy`** *(optional)* — symlinks or copies configuration files to their
  expected locations on disk (e.g. `~/.config/{tool}/`).

### Fallback — language package manager

When tools are available as packages in the language's ecosystem (npm, pip,
go modules), you can declare them in the repository's root dependency file
(`package.json`, `go.mod`) and install via the package manager. The installed
binaries are then available from within the repository.

---

## Argument handling

`{lang}-lint`, `{lang}-fix`, and `{lang}-test` share the same argument
handling convention:

1. **Expand** — directory arguments are expanded recursively to all files they
   contain, as if each file had been passed individually.
2. **Filter** — the expanded list is filtered through `is-{lang}`, keeping only
   files that belong to the language. Non-matching files are silently skipped.

These scripts never read from stdin. All input is passed as file path arguments.

Each script implements these steps internally — there is no shared helper
function. The logic is simple enough that duplicating it is preferable to
adding an abstraction.

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

Detection is not exclusive — a file may match multiple `is-{lang}` checks, and
all matching toolchains apply.

**Dependencies:**

- Used by [`git-file-lint`](integration.md#git-file-lint) to dispatch files to the correct linter
- Used by [`git-file-test`](integration.md#git-file-test) to dispatch files to the correct test runner

---

## `{lang}-lint`

```zsh
# Linter. Reports lint violations.
# Exits 0 when clean, 1 on violations or errors.
# Violations go to stdout. Internal errors (missing config, tool crash) bubble to stderr.
# Accepts files and directories (see Argument handling above).
# Usage:
# $ zsh-lint path/to/file.zsh                          # stylish output (default)
# $ zsh-lint src/foo.zsh src/bar.zsh                   # multiple files
# $ zsh-lint src/                                      # all zsh files in directory
# $ zsh-lint src/foo.zsh lib/                          # mix of files and directories
# $ zsh-lint --json path/to/file.zsh                   # unified JSON (for NeoVim)
# $ zsh-lint --fix path/to/file.zsh                    # format in-place, then report remaining violations
```

**Notes:**

Two output modes:

- **Default (no flag)** — stylish format for terminal use. Violations are
  grouped by file, with an indented `line:column  level  message  rule-id` line
  per violation. When there are no violations, output is empty.
- **`--json`** — unified JSON array for NeoVim.
  See [lint-output.md](lint-output.md) for the schema. When there are no
  violations, output is `[]`.

See [fix-lint-relationship.md](fix-lint-relationship.md) for how `{lang}-lint`
and `{lang}-fix` relate to each other.

Implementation preference ladder, simplest first:

1. Use an external linter with default options
2. Add custom options or rule exclusions
3. Combine multiple external linters (merge their JSON outputs into a single array)

**Dependencies:**

- Used by [`git-file-lint`](integration.md#git-file-lint) to lint changed files
- Used by [NeoVim `filetypes/{lang}.lua`](neovim.md#configurelinterlint) to populate diagnostics
- Used by [`lintstaged.config.js`](integration.md#lintstagedconfigjs) for pre-commit linting

---

## `{lang}-fix`

```zsh
# Formatter. Rewrites code to canonical style.
# Exits 0 on success (including nothing to do), 1 on error.
# No output on stdout (unless --stdout). Errors go to stderr.
# Default: modifies files in-place.
# Accepts files and directories (see Argument handling above).
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

- **`--original-path`** — the real file path on disk. Used to resolve
    language-specific configuration files and rules that depend on the file's name
    or location.
- **`--stdout`** — write the fixed code to stdout instead of modifying the file
    in-place. Intended for manual CLI usage, not used by any automated consumer.

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
# Exits non-zero on failure, 0 on success or when no tests are found.
# All output goes to stdout.
# Accepts files and directories (see Argument handling above).
# After filtering, resolves all files to test files via {lang}-test-path
# and deduplicates before running.
# Usage:
# $ js-test src/__tests__/module.js                          # one test file
# $ js-test src/module.js                                   # source file → resolved via {lang}-test-path
# $ js-test src/                                            # all tests in directory
# $ js-test src/foo.js src/bar.js src/__tests__/baz.js      # mix of sources, tests, directories
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
# $ js-test-path src/module.js        # → src/__tests__/module.js
# $ python-test-path lib/helper.py    # → lib/__tests__/test_helper.py
```

**Notes:**

Source files map to test files in a sibling `__tests__/` directory. The exact naming pattern (`test_module.ext`, `module.test.ext`, `module_test.ext`) varies by language convention. The mapping is a pure string transformation — derive the test path, then check the file exists on disk.

**Dependencies:**

- Used by [`git-file-test`](integration.md#git-file-test) to resolve source files to test files
- Used by [`{lang}-test`](#lang-test) when given a source file

---

## Adding a language

See [Language categories](README.md#language-categories) for which steps apply.

All languages:

1. Install external tools — see [External tool installation](#external-tool-installation)
2. Create [`is-{lang}`](#is-lang) — file detection function
3. Create [`{lang}-lint`](#lang-lint) — linter with `--json` and `--fix` flags
4. Create [`{lang}-fix`](#lang-fix) — formatter with `--stdout` and `--original-path` flags

Programming languages only:

5. Create [`{lang}-test`](#lang-test) — test runner
6. Create [`{lang}-test-path`](#lang-test-path) — source-to-test file mapper
