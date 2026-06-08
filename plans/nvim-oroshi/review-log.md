## Issue 02 — Fix statusline hardcoded path

### No nil-guard on vim.env.OROSHI_ROOT

```lua
local distPath = vim.env.OROSHI_ROOT .. "/tools/term/zsh/config/theming/dist/projects.json"
```

**Problem:** Spec agent noted that if `$OROSHI_ROOT` is unset, the Lua concatenation will error at runtime.

**Reason skipped:** GUIDANCE.md explicitly documents "$OROSHI_ROOT is always set by zshenv — no fallback needed in Lua". This is a project-wide convention; adding a guard here would be inconsistent with all other usages.
