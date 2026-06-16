# FZF

The new FZF system — executable scripts in `scripts/bin/fzf/` that replace the Legacy FZF autoloaded functions. Each script exposes a consistent interface for ZSH keybinding widgets and Neovim.

## Language

**FZF Script**:
An executable `#!/bin/zsh` script in `scripts/bin/fzf/` that implements one FZF-powered search feature.
_Avoid_: FZF function, FZF command, FZF entry

**Lifecycle Functions**:
The four functions defined inside every **FZF Script**: `fzf-source`, `fzf-options`, `fzf-postprocess`, and `fzf-main`.
_Avoid_: Pipeline functions, internal functions, hooks

**fzf-source**:
The **Lifecycle Function** that generates FZF candidates — one entry per line on stdout.
_Avoid_: source, get-source, list

**fzf-options**:
The **Lifecycle Function** that outputs FZF CLI flags — one flag per line on stdout.
_Avoid_: options, get-options, config

**fzf-postprocess**:
The **Lifecycle Function** that receives raw FZF selection on stdin and returns a clean, usable result on stdout.
_Avoid_: postprocess, sink, sinklist, post-process

**fzf-main**:
The **Lifecycle Function** that assembles the full pipeline — invoked when the **FZF Script** is called with no arguments.
_Avoid_: main, run, execute

**FZF Helpers**:
`.zsh` files in `scripts/bin/fzf/__lib/` that are sourced (not executed) by **FZF Scripts** to share common functions across scripts. Each file is named after the single function it exports (e.g. `fzf-options-base.zsh` exports `fzf-options-base`).
_Avoid_: shared library, helpers, utils, _shared

**Neovim API**:
The `--source` / `--options` / `--postprocess` argument interface that allows Neovim to invoke individual **Lifecycle Functions** separately via `fzf#run()`.
_Avoid_: dispatch interface, lifecycle API, vim API

**Legacy FZF**:
The previous FZF system — autoloaded ZSH functions in `tools/term/zsh/config/functions/autoload/fzf/` using the `fzf-search` orchestrator pattern.
_Avoid_: old system, autoload FZF

## Relationships

- A **FZF Script** contains exactly four **Lifecycle Functions**
- A **FZF Script** may source zero or more **FZF Helpers**
- **fzf-main** assembles the pipeline: `fzf-source | fzf $(fzf-options) | fzf-postprocess`
- **fzf-postprocess** always receives its input via stdin (never via argument)
- The **Neovim API** exposes **fzf-source**, **fzf-options**, and **fzf-postprocess** individually — never **fzf-main**
- A ZSH keybinding widget calls a **FZF Script** with no arguments, triggering **fzf-main**
- **FZF Helpers** are sourced at the top of a **FZF Script** — their functions are available to all **Lifecycle Functions**

## Flagged ambiguities

- "postprocess" vs "sinklist": Neovim's `sinklist` is NOT the same as `fzf-postprocess` — `sinklist` is a Lua callback that calls `fzf-postprocess` and then performs editor-specific actions (tab drop, line jump). They are two distinct layers.
- "source" as a term was avoided because it shadows the ZSH builtin `source` — `fzf-source` is the canonical name.

## Example dialogue

> **Dev:** "How does Neovim call Ctrl-P?"
> **Domain expert:** "It uses the **Neovim API** — calls `ctrl-p --source` and `ctrl-p --options` separately, passes them to `fzf#run()`, then its `sinklist` calls `ctrl-p --postprocess` to clean the selection."

> **Dev:** "Why does `fzf-postprocess` use stdin?"
> **Domain expert:** "So **fzf-main** can pipe directly: `fzf-source | fzf $(fzf-options) | fzf-postprocess` — no intermediate variable needed."
