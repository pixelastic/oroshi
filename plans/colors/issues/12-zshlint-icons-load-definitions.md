## TLDR

Design a custom zshlint rule that enforces `icons-load-definitions` is called in any ZSH function that accesses `$ICONS[...]`.

## Problem

Same problem as issue 11 but for `$ICONS[...]`. Functions that use `$ICONS[...]` rely on `theming/index.zsh` having sourced `theming/icons.zsh`. The dependency is implicit and invisible to the linter.

## Open questions

Same design questions as issue 11, applied to `$ICONS[...]` and `icons-load-definitions`:

- File vs. function scope for the call?
- Autoloaded functions only, or also scripts?
- What counts as "uses `$ICONS[...]`" — just `$ICONS[key]`, or also `${(k)ICONS}`, `${#ICONS}`?
- Legitimate exceptions (the icons loader itself, `theming/index.zsh`)?
- Should this rule be implemented alongside the COLORS rule (issue 11) or separately?

## Process

1. Run `/grill-me` on the design questions above
2. Write a new implementation issue for the zshlint rule based on the decisions reached

## Done when

A new issue exists that specifies how to implement the zshlint rule, with acceptance criteria derived from the grill-me session.
