## Problem Statement

Lua files in the Neovim config have no CLI-accessible testing or linting toolchain. Linting currently happens only through the LSP inside Neovim, which means agents and pre-commit hooks cannot verify Lua code quality, and there is no way to enforce project-specific conventions (e.g. "use `F.clone` instead of `vim.deepcopy`") outside of the editor. There is also no test framework for Lua utility functions, making TDD impossible for Lua code.

## Solution

Build a Lua toolchain mirroring the existing ZSH toolchain:

- `lua-lint` — a CLI linter wrapping selene (static analysis) and a custom rules runner, outputting a unified JSON array of violations. Mirrors `zshlint`.
- `lua-test` — a CLI test runner launching Neovim in headless mode via `mini.test`. Mirrors `bats`.
- `lua-test-path` — a standalone helper resolving a Lua source file to its corresponding spec file. Mirrors `bats-test-path`.
- Both tools are wired into lint-staged so they run automatically on pre-commit for all Neovim Lua files.
- The Neovim `lua` filetype config is updated to use `lua-lint` as its linter, ensuring consistent results between the editor and the CLI.

## User Stories

1. As a developer, I want to run `lua-lint path/to/file.lua` from the terminal so that I can see lint violations without opening Neovim.
2. As a developer, I want `lua-lint` to output a JSON array of violations so that its output is machine-readable and consistent with `zshlint`.
3. As a developer, I want selene to catch standard Lua and Neovim API misuse so that common errors are flagged automatically.
4. As a developer, I want custom rules that flag discouraged patterns so that project conventions are enforced in the same tool.
5. As a developer, I want the first custom rule to flag `vim.deepcopy` and suggest `F.clone` so that the custom rules infrastructure is validated end-to-end.
6. As a developer, I want to add new custom rules as individual ZSH files so that the rule list can grow without modifying the core tooling.
7. As a developer, I want to run `lua-test path/to/file_spec.lua` from the terminal so that I can run Lua tests without opening Neovim.
8. As a developer, I want `lua-test` to accept a source file and resolve its spec automatically so that I do not need to remember the spec file path.
9. As a developer, I want `lua-test-path path/to/file.lua` to return the path of the corresponding spec file so that other tools can discover specs programmatically.
10. As a developer, I want `lua-test-path` to exit silently with no output if no spec exists so that it is safe to call unconditionally.
11. As an agent, I want to run `lua-lint` and `lua-test` on any Lua file so that I can verify my changes as part of a TDD loop.
12. As a developer, I want lint and tests to run automatically on staged Lua files before each commit so that regressions are caught before they land.
13. As a developer, I want to install selene with a single script consistent with the rest of the install scripts so that the setup is reproducible.
14. As a developer, I want `mini.test` installed as a regular lazy.nvim plugin so that it requires no separate bootstrap step.
15. As a developer, I want Neovim to display `lua-lint` violations inline via nvim-lint so that the editor and CLI show consistent results.
16. As a developer, I want the Neovim Lua linter to no longer rely solely on `lua_ls` diagnostics for linting so that project-specific rules are visible inside the editor.

## Implementation Decisions

### lua-lint architecture (mirrors zshlint)

`lua-lint` is an orchestrator that calls two sub-tools in sequence:

- `lua-lint-selene` — wraps the selene binary, translates its output into the common violation format
- `lua-lint-custom` — sources all rule files from a `__rules/` directory, runs each against the target file, collects results

Both sub-tools output lines in the format `file▮code▮level▮line▮message` (using the Unicode separator `\u25ae`, same as `zshlint-custom`). `lua-lint` merges both streams and serialises the result as a JSON array. Exit code is 1 if any violations were found, 0 if clean.

### lua-lint-selene

Selene is invoked on the target file. Its output is parsed and converted into the common violation format. The selene binary must be installed and on PATH. A `selene.toml` config file lives at the root of the Neovim config directory and declares the `vim` standard library so that `vim.*` globals are not flagged as unknown.

### Custom rules

Each rule is a ZSH function in a `__rules/` directory, following exactly the same interface as `zshlint` custom rules:

- The function receives the file path
- It scans the file content for violations
- It prints one line per violation in the common format

First rule: flag any call to `vim.deepcopy(` and suggest using `F.clone` instead.

### lua-test architecture

`lua-test` is a ZSH script that:

1. If the input ends with `_spec.lua`, runs it directly
2. Otherwise, calls `lua-test-path` to resolve the spec; if none found, exits 0 silently

Running a spec means invoking `nvim --headless -l config/vim/nvim/config/minit.lua -- <spec_path>`.

`minit.lua` prepends the path to the `mini.test` plugin (installed by lazy.nvim into the standard lazy data directory) onto the runtime path, then calls `MiniTest.run_file()` on the spec passed as argument.

### lua-test-path

Standalone ZSH script following the same logic as `bats-test-path`:

- If input is already a `_spec.lua` file, return it directly (after checking it exists)
- Otherwise, construct `<dir>/__tests__/<basename>_spec.lua` and return it if the file exists
- Exit 1 with no output if nothing found

### mini.test installation

`mini.test` (`echasnovski/mini.test`) is declared as a lazy.nvim plugin in the existing plugin spec. No auto-bootstrap or additional install script is needed.

### selene installation

A new install script is added following the existing pattern for GitHub release binaries: download the Linux amd64 binary from the selene GitHub releases page, install it to `~/local/bin/selene`, and `chmod +x`.

### Neovim Lua filetype config

The existing `lua.lua` filetype module gains a `configureLinter` function that registers `lua-lint` as a custom nvim-lint linter for the `lua` filetype. The linter is invoked via a shell command, and its JSON output is parsed to populate Neovim diagnostics. This replaces reliance on `lua_ls` for linting (LSP remains active for completion and go-to-definition).

### Pre-commit integration

`lintstaged.config.js` gains a new pattern matching all Lua files under the Neovim config directory. Staged Lua files are passed to both `lua-lint` and `lua-test`.

### CLAUDE.md

The project `CLAUDE.md` is updated with:
- `lua-test <filepath>` for running Lua tests
- `lua-lint <filepath>` for running the Lua linter

## Testing Decisions

Good tests verify observable behaviour from the outside, not implementation details. They use real inputs and assert on output or exit code.

### lua-lint-selene (BATS)

- Happy path: given a file with a known selene violation, assert the output contains the expected violation code and the exit code is 1
- Clean path: given a file with no violations, assert exit code is 0 and output is empty

Prior art: `scripts/bin/zsh/zshlint/__tests__/`

### lua-lint-custom (BATS)

- Given a file containing `vim.deepcopy(`, assert the violation for `rule-no-vim-deepcopy` appears in the output
- Given a clean file, assert no output

Prior art: `scripts/bin/zsh/zshlint/__tests__/`

### lua-lint orchestrator (BATS)

- When both sub-tools return violations, assert the merged JSON contains violations from both
- When only one sub-tool returns violations, assert the JSON contains those violations and exit code is 1
- When neither returns violations, assert JSON is empty array and exit code is 0

Prior art: `scripts/bin/zsh/zshlint/__tests__/`

### rule-no-vim-deepcopy (BATS)

- Given a line containing `vim.deepcopy(`, assert a violation is reported at the correct line number
- Given a line not containing `vim.deepcopy`, assert no violation

Prior art: `scripts/bin/zsh/zshlint/__tests__/rule-no-while-read.bats`

### lua-test-path (BATS)

- Given a `_spec.lua` file that exists, assert the path is returned as-is
- Given a `_spec.lua` file that does not exist, assert exit 1
- Given a source `.lua` file whose spec exists, assert the spec path is returned
- Given a source `.lua` file with no spec, assert exit 1 and no output

Prior art: `scripts/bin/term/bats/__tests__/bats-test-path.bats`

## Out of Scope

- Writing actual `_spec.lua` test files for existing Lua utility modules (lodash, collections, etc.) — the tooling must exist first
- Additional custom lint rules beyond `rule-no-vim-deepcopy` — infrastructure is validated with one rule; more rules are added in future issues
- Windows or non-amd64 Linux support for the selene install script
- A `lua-fix` auto-fix tool
- Testing the `minit.lua` bootstrap in isolation
