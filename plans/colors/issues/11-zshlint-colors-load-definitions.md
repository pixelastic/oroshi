## TLDR

Design a custom zshlint rule that enforces `colors-load-definitions` is called in any ZSH function that accesses `$COLORS[...]`.

## Problem

ZSH functions that use `$COLORS[...]` rely on `theming/index.zsh` having run first. Nothing enforces this — a function can silently use `$COLORS[...]` without declaring its dependency, and it works in a live shell but breaks in isolation (tests, scripts called directly). The convention is undocumented and invisible to the linter.

## Open questions

Before writing an implementation issue, the following design questions need answers:

- Where exactly should `colors-load-definitions` appear in a function — top of function body, or top of file?
- Does the rule apply to autoloaded functions only, or also to scripts with a shebang?
- What constitutes "uses `$COLORS[...]`" — just `$COLORS[key]`, or also `${(k)COLORS}`, `${#COLORS}`, etc.?
- Are there legitimate exceptions (e.g. `colors-load-definitions` itself, `theming/index.zsh`)?
- How does this interact with the existing guard pattern — is `colors-load-definitions` at the top of a function that has `((${#COLORS} > 0)) && return` itself valid?

## Process

1. Run `/grill-me` on the design questions above
2. Write a new implementation issue for the zshlint rule based on the decisions reached

## Done when

A new issue exists that specifies how to implement the zshlint rule, with acceptance criteria derived from the grill-me session.
