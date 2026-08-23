# External Utilities

Utilities referenced throughout the toolchain documentation but maintained
outside it. Each section describes what the tool does and why the toolchain
needs it.

---

## `bin-zsh`

```zsh
# Wrapper that executes ZSH autoloaded functions from non-ZSH contexts.
# Location: scripts/bin/bin-zsh
# Usage:
# $ bin-zsh zsh-lint path/to/file.zsh          # call an autoloaded function
# $ bin-zsh git-branch-current --verbose        # with arguments
```

All toolchain scripts are ZSH autoloaded functions — they are sourced
automatically by ZSH and available as commands in any ZSH shell. However,
callers that run outside ZSH (NeoVim's Lua runtime, RTK's shell invocation)
cannot access them directly. `bin-zsh` bridges this gap: it is a ZSH script
on the PATH that receives a function name and arguments, and executes them
in a ZSH context where autoloaded functions are available.

Used by:

- [NeoVim](neovim.md) — all `configureLinter` and `configureFormatter` commands
  are prefixed with `bin-zsh`
- [RTK](#rtk) — `rtk-command-rewrite` prepends `bin-zsh` so RTK can invoke
  autoloaded test commands

---

## `lint-staged`

```js
// Pre-commit runner that executes lint and test commands on staged files.
// Source: https://github.com/lint-staged/lint-staged
// Config: lintstaged.config.js (repository root)
```

lint-staged is invoked automatically at pre-commit time via a git hook. It
reads [`lintstaged.config.js`](integration.md#lintstagedconfigjs), matches
staged files against glob patterns, and runs the configured lint and test
commands on them. If any command exits non-zero, the commit is blocked.

Used by:

- [integration.md](integration.md#lintstagedconfigjs) — per-language glob
  patterns route staged files to `{lang}-lint --fix` and `{lang}-test`

---

## `rtk`

```zsh
# CLI proxy that filters command output to reduce token usage for AI agents.
# Source: https://github.com/algolia/rtk
# Install: tools/ai/rtk/install
# Config:  tools/ai/rtk/config/filters.toml → ~/.config/rtk/filters.toml
# Usage:
# $ rtk python-test tests/          # runs command, filters output
# $ rtk bin-zsh js-test src/         # runs via bin-zsh, filters output
```

RTK wraps a command, captures its output, and applies per-command regex
filters to strip noise — passing tests, timing info, progress bars, ANSI
escape codes. When all output is stripped (i.e. all tests passed), it emits
a short summary message instead of the full output.

Filter rules live in `filters.toml`, which maps command patterns to
strip/replace rules. See
[integration.md](integration.md#rtk--test-output-filtering-for-agents) for
how the toolchain configures filters and command rewriting for each language.

---

## `file-expand`

```zsh
# Expands directories to files, filters, and optionally maps paths.
# Output is deduplicated absolute paths, one per line.
# Location: tools/term/zsh/config/functions/autoload/misc/file/file-expand
# Usage:
# $ file-expand src/                                           # all files recursively
# $ file-expand --filter is-go src/                            # only Go files
# $ file-expand --filter is-go --map go-test-path src/         # Go files → test paths
# $ file-expand file1.go dir/ file2.go                         # mixed files and directories
```

Shared helper used by [`{lang}-lint`](scripts.md#lang-lint),
[`{lang}-fix`](scripts.md#lang-fix), and [`{lang}-test`](scripts.md#lang-test)
for [argument handling](scripts.md#argument-handling). Accepts files and
directories as positional arguments. Directories are expanded recursively
using `fd --type file` (respects `.gitignore`).

Optional flags:

- **`--filter <cmd>`** — keep only files where `<cmd> <file>` returns exit 0.
  Files that fail are silently dropped.
- **`--map <cmd>`** — transform each remaining path by calling `<cmd> <file>`.
  If the command fails (exit non-zero), skip that file silently.

Processing order: expand → filter → map → deduplicate.

Used by:

- [scripts.md](scripts.md#argument-handling) — all `{lang}-lint`, `{lang}-fix`,
  and `{lang}-test` use it for argument expansion and filtering
