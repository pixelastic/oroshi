# NeoVim Integration

NeoVim provides inline diagnostics, format-on-save, and syntax highlighting for
every supported language. The integration bridges per-language ZSH scripts into
NeoVim's plugin ecosystem through a thin Lua layer — each language gets a
filetype module that registers its linter and formatter, and a central plugin
registry that ties everything together.

See [scripts.md](scripts.md) for the per-language ZSH functions these modules
call.

Since all toolchain scripts are ZSH autoloaded functions (not standalone
binaries), NeoVim must call them through `bin-zsh` — a wrapper that executes its
arguments in a ZSH context. All commands in `configureLinter` and
`configureFormatter` are prefixed with `bin-zsh` for this reason.

---

## `code-quality.lua`

```lua
-- Central plugin registry for linting, formatting, LSP, and treesitter.
-- Location: tools/vim/nvim/config/lua/oroshi/plugins/enabled/code-quality.lua
-- Declares all language dependencies and per-filetype configuration
-- in a single file.
```

### `config.dependencies.mason`

LSP servers to install. These run dynamically inside NeoVim — they are the only
language tools that don't live in the PATH as standalone binaries. Mason
auto-installs declared servers and uninstalls undeclared ones.

### `config.dependencies.treesitter`

Syntax highlighting parsers to install. Treesitter auto-installs declared
parsers and uninstalls undeclared ones. The parser name usually matches the
filetype name (e.g. `go`, `python`, `javascript`) — check the nvim-treesitter
supported languages list. If no parser exists for a language, syntax
highlighting falls back to Vim's regex-based highlighting.

### `config.filetypes`

Per-filetype table defining which linter, formatter, and LSP server to use for
each language. Two phases work together: `configure*` functions register custom
tools at startup, then `linters`/`formatters` lists reference them by name.


| Key                  | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `configureLinter`    | Registers a custom linter in nvim-lint (name, command, parser). Called once at startup. |
| `configureLsp`       | Customizes an LSP server's settings. Called once at startup.                |
| `configureFormatter` | Registers a custom formatter in conform.nvim (name, command, stdin mode). Called once at startup. |
| `linters`            | List of linter names to activate — custom (registered above) or built-in    |
| `formatters`         | List of formatter names to activate — custom (registered above) or built-in |
| `lsp`                | LSP server name(s) for this filetype                                        |
| `formatterTimeout`   | Timeout in milliseconds for format-on-save (for slow formatters)            |

**Dependencies:**

- Uses [`filetypes/{lang}.lua`](#filetypeslanglua) for per-language configuration
- Manages LSP servers via Mason
- Manages [treesitter parsers](#configdependenciestreesitter)

---

## `filetypes/{lang}.lua`

```lua
-- Per-language NeoVim configuration module.
-- Location: tools/vim/nvim/config/lua/oroshi/filetypes/{lang}.lua
-- Exports a module M with functions that register linting and formatting
-- for one language, plus optional filetype detection and buffer setup.
```

### `configureLinter(lint)`

Registers a custom linter with nvim-lint. Specifies the command (`bin-zsh
{lang}-lint`), args (`--json` and the filename), and stdin mode. The linter name
is registered in nvim-lint's `linters` table so it can be referenced by name in
`code-quality.lua`.

Since every [`{lang}-lint --json`](scripts.md#lang-lint) produces the same
[unified lint JSON schema](lint-output.md), the diagnostic parser is shared
across all languages.

### `configureFormatter(conform)`

Registers a custom formatter with conform.nvim.

Command: `bin-zsh {lang}-fix --stdin --filepath $FILENAME`.

- `bin-zsh`: because `{lang}-fix` is a ZSH autoloaded function
- `--stdin`: conform.nvim pipes the buffer content; this tells `{lang}-fix` to
read it from stdin rather than from a filepath
- `--filepath`: the real file path, so the script can resolve configuration

### `onInit()` *(optional)*

Filetype detection logic for files that cannot be identified by extension alone
(e.g. extensionless ZSH autoload functions in specific directories). Runs once
at startup.

### `onFiletype()` *(optional)*

Buffer-local keymaps or settings applied when a buffer of this filetype is
opened (e.g. indentation overrides, comment string settings).

**Dependencies:**

- Calls [`{lang}-lint --json`](scripts.md#lang-lint) for diagnostics
- Calls [`{lang}-fix --stdin --filepath`](scripts.md#lang-fix) for format-on-save
- Referenced by [`code-quality.lua`](#code-qualitylua) to wire into the plugin system

---

## Adding a language

1. Create `filetypes/{lang}.lua` with `configureLinter` and `configureFormatter`
   (and optionally `onInit` / `onFiletype`)
2. In `code-quality.lua`: import the filetype helper and add an entry in
   `config.filetypes` referencing its configure functions
3. Add the LSP server to `config.dependencies.mason`
4. Add the treesitter parser to `config.dependencies.treesitter`
