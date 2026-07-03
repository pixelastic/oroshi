## Problem Statement

Tab completion uses the native ZSH interface. There is no way to invoke fzf-based completion on demand — the user either has all completions go through fzf (which was tried and reverted because it felt too aggressive) or none do.

## Solution

Bind Shift-Tab to fzf-based completion using fzf-tab, while leaving Tab untouched. Pressing Tab continues to use the native ZSH completion interface. Pressing Shift-Tab triggers the same completion candidates, but presented in fzf for fuzzy selection. The fzf prompt matches the visual style of other oroshi fzf keybindings (colored badge with icon and label).

## User Stories

1. As a shell user, I want Tab to continue using native ZSH completion, so that my default completion behavior is unchanged.
2. As a shell user, I want Shift-Tab to open an fzf picker with the same completion candidates as Tab, so that I can fuzzy-search among them when the list is long.
3. As a shell user, I want Shift-Tab completion to work for all completion types (files, command arguments, git branches, etc.), so that fzf-based completion is as powerful as native completion.
4. As a shell user, I want the fzf picker opened by Shift-Tab to display a prompt badge consistent with other oroshi fzf keybindings (Ctrl-B, Ctrl-R), so that the UI feels cohesive.
5. As a shell user, I want the async prompt refresh to be suppressed during Shift-Tab fzf completion, so that the terminal display is not corrupted.
6. As a shell user, I want the fzf-completion icon to be easily customizable, so that I can update it to my preference later.

## Implementation Decisions

- **fzf-tab** (already installed at `~/local/etc/fzf-tab/`) is used as the completion capture mechanism. It patches the `compadd` builtin to intercept all completion candidates and passes them to fzf. This makes it work for all completion types, not just files.
- fzf-tab auto-runs `enable-fzf-tab` on source, which hijacks `^I` (Tab) to `fzf-tab-complete`. Immediately after sourcing, `^I` is reverted back to `oroshi-tab-widget` to restore native Tab behavior.
- A wrapper widget `oroshi-shift-tab-widget` is created, wrapping `fzf-tab-complete` with `PROMPT_PREVENT_REFRESH=1/0` — the same pattern used by `oroshi-tab-widget` and other oroshi fzf widgets — to prevent async prompt corruption.
- `^[[Z` (the standard ANSI escape sequence for Shift-Tab, including in kitty) is bound to `oroshi-shift-tab-widget`.
- The fzf prompt badge is configured via `zstyle ':fzf-tab:*' fzf-flags`, using the existing `fzf-options-prompt-label` helper with the `fzf-completion` icon key, label "Completion", colors `teal` / `teal-dark`. The prompt string is computed once at shell startup.
- `--color=prompt::regular` is added to suppress fzf's default bold prompt styling, consistent with other oroshi fzf scripts.
- A new icon `ICONS[fzf-completion]` is added in the fzf section of the icons definitions file, using a bidirectional arrows glyph as a temporary placeholder.
- The existing TODO comment referencing fzf-tab in the keybindings index is removed.

## Testing Decisions

No automated tests for this feature. The modules touched are keybinding configuration files and icon definitions — these are configuration artifacts, not logic. Per project convention, config changes are the artifact themselves and do not require bats test coverage.

## Out of Scope

- Styling fzf-tab output (candidate colors, icons per file type, previews) — this is a separate concern.
- Integrating fzf-tab with the `ICONS` / `COLORS` system beyond the prompt badge.
- Making the prompt badge dynamic (e.g., showing `$PWD` like Ctrl-P does) — the static badge is sufficient for a completion context.
- Configuring fzf-tab per-context (e.g., different behavior for `cd` vs `git checkout`).
