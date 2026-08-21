# Language Toolchain

A language toolchain is the full set of ZSH scripts, configuration files, and conventions that make a programming language a first-class citizen in this codebase. Each toolchain provides linting, fixing, testing, editor integration, and AI assistance through a uniform interface — allowing every language to plug into shared dispatchers, NeoVim diagnostics, and CI pipelines without special-casing.

## Detail files

- [**scripts.md**](scripts.md) — Per-language ZSH functions: `is-{lang}`, `{lang}-lint`, `{lang}-fix`, `{lang}-test`, `{lang}-test-path`, and their contracts.
- [**fix-lint-relationship.md**](fix-lint-relationship.md) — How `{lang}-fix`, `{lang}-lint`, and `{lang}-lint --fix` relate to each other, and how implementations may optimize internally.
- [**lint-output.md**](lint-output.md) — Lint output formats: default stylish for terminal, `--json` unified schema for machine consumers.
- [**integration.md**](integration.md) — Shared dispatchers, pre-commit hooks, shell completion, and other cross-language configuration.
- [**agents.md**](agents.md) — AI integration: how Claude Code skills invoke the toolchain, and conventions for agent-driven linting, testing, and fixing.
- [**neovim.md**](neovim.md) — NeoVim integration: diagnostics from unified lint JSON and format-on-save via `{lang}-fix`.
