# FZF

The new FZF system — executable scripts in `scripts/bin/fzf/` that replace the Legacy FZF autoloaded functions. Each script exposes a consistent interface for ZSH keybinding widgets and Neovim.

## Language

**FZF Script**:
An executable `#!/bin/zsh` script in `scripts/bin/fzf/` that implements one FZF-powered search feature.
_Avoid_: FZF function, FZF command, FZF entry

**Lifecycle Functions**:
The five functions that can be defined inside a **FZF Script**: `fzf-source`, `fzf-options`, `fzf-preview`, `fzf-postprocess`, and `fzf-main`.
_Avoid_: Pipeline functions, internal functions, hooks

**fzf-source**:
The **Lifecycle Function** that generates FZF candidates — one entry per line on stdout.
_Avoid_: source, get-source, list

**fzf-options**:
The **Lifecycle Function** that outputs FZF CLI flags — one flag per line on stdout.
_Avoid_: options, get-options, config

**fzf-preview**:
The **Lifecycle Function** that renders the preview pane for the currently highlighted candidate — receives the candidate as `$1`, outputs preview content on stdout.
_Avoid_: preview script, preview helper, preview command

**fzf-postprocess**:
The **Lifecycle Function** that receives raw FZF selection on stdin and returns a clean, usable result on stdout.
_Avoid_: postprocess, sink, sinklist, post-process

**fzf-main**:
The **Lifecycle Function** that assembles the full pipeline — invoked when the **FZF Script** is called with no arguments. `init.zsh` provides the default implementation; scripts can override it after sourcing.
_Avoid_: main, run, execute

**Prompt**:
The string displayed top-left in the FZF window before user input.
If the source lists files or directories: **context-badge** (+ simplified path if scope = cwd, badge only if scope = git root).
If the source lists anything else: **icon + label** (`$ICONS[...]` + 1–2 word description).
_Avoid_: header, title, prefix

**FZF Helpers**:
`.zsh` files in `scripts/bin/fzf/__lib/` that are sourced (not executed) by **FZF Scripts** to share common functions across scripts. Each file is named after the single function it exports (e.g. `fzf-options-prompt-label.zsh` exports `fzf-options-prompt-label`).
_Avoid_: shared library, helpers, utils, _shared

**fzf-dispatch**:
The dispatcher function defined by `init.zsh` — handles standard flags (`--source`, `--options`, `--postprocess`, `--preview`, `--no-dispatch`), then falls through to **fzf-main**.
Every **FZF Script** calls `fzf-dispatch` at the bottom.
`--no-dispatch` makes `fzf-dispatch` return immediately without calling any **Lifecycle Function** — allows sourcing a script to load its function definitions without executing.
_Avoid_: fzf-run, fzf-init

**Neovim API**:
The `--source` / `--options` / `--postprocess` argument interface that allows Neovim to invoke individual **Lifecycle Functions** separately via `fzf#run()`.
_Avoid_: dispatch interface, lifecycle API, vim API

**Legacy FZF**:
The previous FZF system — autoloaded ZSH functions in `tools/term/zsh/config/functions/autoload/fzf/` using the `fzf-search` orchestrator pattern.
_Avoid_: old system, autoload FZF

## Relationships

- A **FZF Script** contains up to five **Lifecycle Functions** (four required, **fzf-preview** optional)
- A **FZF Script** may source zero or more **FZF Helpers**
- **fzf-main** assembles the pipeline: `fzf-source | fzf $(fzf-options) | fzf-postprocess`
- **fzf-postprocess** always receives its input via stdin (never via argument)
- The **Neovim API** exposes **fzf-source**, **fzf-options**, **fzf-postprocess**, and **fzf-preview** individually — never **fzf-main**
- A ZSH keybinding widget calls a **FZF Script** with no arguments — **fzf-dispatch** dispatches to **fzf-main**
- **FZF Helpers** are sourced at the top of a **FZF Script** — their functions are available to all **Lifecycle Functions**

## Flagged ambiguities

- "postprocess" vs "sinklist": Neovim's `sinklist` is NOT the same as `fzf-postprocess` — `sinklist` is a Lua callback that calls `fzf-postprocess` and then performs editor-specific actions (tab drop, line jump). They are two distinct layers.
- "source" as a term was avoided because it shadows the ZSH builtin `source` — `fzf-source` is the canonical name.

## Example dialogue

> **Dev:** "How does Neovim call Ctrl-P?"
> **Domain expert:** "It uses the **Neovim API** — calls `ctrl-p --source` and `ctrl-p --options` separately, passes them to `fzf#run()`, then its `sinklist` calls `ctrl-p --postprocess` to clean the selection."

> **Dev:** "Why does `fzf-postprocess` use stdin?"
> **Domain expert:** "So **fzf-main** can pipe directly: `fzf-source | fzf $(fzf-options) | fzf-postprocess` — no intermediate variable needed."
