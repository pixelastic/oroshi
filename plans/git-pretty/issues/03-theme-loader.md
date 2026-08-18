## TLDR

Go module that reads oroshi's color/icon JSON files and resolves branch/remote colors.

## What to build

A `theme` package that:

1. Reads `$OROSHI_ROOT/tools/term/zsh/config/theming/dist/colors.json` — returns ANSI color index by name
2. Reads `$OROSHI_ROOT/tools/term/zsh/config/theming/dist/icons.json` — returns icon glyph by name
3. Calls `bin-zsh git-branch-color <branchName>` to get the dynamic color for a specific branch
4. Calls `bin-zsh git-remote-color <remoteName>` to get the dynamic color for a specific remote
5. Converts ANSI color indices to lipgloss colors for use in the TUI

The theme is loaded once at startup. The JSON files have this shape:
- colors.json: `{ "git-branch": { "ansi": 73, "hex": "#..." }, ... }`
- icons.json: `{ "git-branch-ahead": "", ... }`

## Behavioral Tests

**JSON loading:**
- Loads color by name and returns ANSI index
- Loads icon by name and returns glyph string
- Returns fallback/error for unknown keys

**Dynamic color resolution:**
- Calls bin-zsh and parses the returned color index

## Acceptance criteria

- [ ] Colors loaded from JSON, accessible by name
- [ ] Icons loaded from JSON, accessible by name
- [ ] Branch color resolved via bin-zsh helper
- [ ] Remote color resolved via bin-zsh helper
- [ ] Lipgloss color conversion works
