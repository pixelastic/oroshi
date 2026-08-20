# Language Toolchain

A language toolchain is the full set of ZSH scripts, configuration files, and conventions that make a programming language a first-class citizen in this codebase. Each toolchain provides linting, fixing, testing, editor integration, and AI assistance through a uniform interface — allowing every language to plug into shared dispatchers, NeoVim diagnostics, and CI pipelines without special-casing.

## Detail files

- [**scripts.md**](scripts.md) — Per-language ZSH functions: `{lang}-lint`, `{lang}-fix`, `{lang}-test`, `{lang}-test-path`, and their contracts.
- [**integration.md**](integration.md) — Shared dispatchers (`git-file-lint`, `git-file-test`, `lintstaged`), language detection (`is-{lang}`), and configuration conventions.
- [**neovim.md**](neovim.md) — NeoVim integration: diagnostics from unified lint JSON, format-on-save via `{lang}-fix`, and test runner keybindings.
- [**agents.md**](agents.md) — AI integration: how Claude Code skills invoke the toolchain, and conventions for agent-driven linting, testing, and fixing.
