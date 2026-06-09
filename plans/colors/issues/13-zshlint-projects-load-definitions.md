## TLDR

Design a custom zshlint rule that enforces `projects-load-definitions` is called in any ZSH function that accesses `$PROJECTS[...]`.

## Problem

Same problem as issues 11 and 12 but for `$PROJECTS[...]`. Functions that use `$PROJECTS[...]` rely on `theming/index.zsh` or an explicit caller having run `projects-load-definitions`. The dependency is implicit and invisible to the linter.

## Open questions

Same design questions as issues 11 and 12, applied to `$PROJECTS[...]` and `projects-load-definitions`:

- File vs. function scope for the call?
- Autoloaded functions only, or also scripts?
- What counts as "uses `$PROJECTS[...]`" — just `$PROJECTS[key]`, or also `${(k)PROJECTS}`, `${#PROJECTS}`?
- Legitimate exceptions (the projects loader itself, `theming/index.zsh`)?
- Should all three rules (COLORS, ICONS, PROJECTS) share the same implementation pattern or be three separate rules?

## Process

1. Run `/grill-me` on the design questions above
2. Write a new implementation issue for the zshlint rule based on the decisions reached

## Done when

A new issue exists that specifies how to implement the zshlint rule, with acceptance criteria derived from the grill-me session.
