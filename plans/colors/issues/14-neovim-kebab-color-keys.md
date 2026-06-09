## TLDR

Migrate all NeoVim Lua color references from `"UPPERCASE_SNAKE"` to `"kebab-case"`, matching the official convention established in issue 09.

## Motivation

After issue 09, `dist/colors.json` uses kebab-case keys. The current NeoVim code works via a shim in `colorscheme/init.lua` that converts kebab → `UPPERCASE_SNAKE` at load time. This shim should be removed: the Lua layer should use the same key format as everything else.

## What to build

### 1. `colorscheme/init.lua` — remove the shim

Replace the `UPPERCASE_SNAKE` conversion with a direct kebab store:

```lua
-- Before
local luaKey = name:upper():gsub("-", "_")
O.colors.env[luaKey] = entry.hex

-- After
O.colors.env[name] = entry.hex
```

### 2. `functions/highlight.lua` — fix dot-notation accesses

Lua dot notation is incompatible with `-`. Two hardcoded references need bracket notation:

```lua
-- Before
config = { fg = O.colors.env.WHITE, bg = O.colors.env.CYAN, bold = true }
config = { fg = O.colors.env.WHITE, bg = O.colors.env.PURPLE }

-- After
config = { fg = O.colors.env["white"], bg = O.colors.env["cyan"], bold = true }
config = { fg = O.colors.env["white"], bg = O.colors.env["purple"] }
```

### 3. All color string references — convert to kebab

Mechanical transformation across all Lua files: every color name passed as a string to `hl()` or stored in a table goes from `"UPPERCASE_SNAKE"` to `"kebab-case"`.

Files to update (identified by grep for `"[A-Z][A-Z_]*"`):

- `colorscheme/ui.lua`
- `colorscheme/syntax.lua`
- `colorscheme/unused.lua`
- `filetypes/gitcommit.lua`
- `filetypes/scrollback_pager.lua`
- `functions/ai.lua`
- `functions/highlight.lua`
- `functions/misc.lua`
- `functions/modes.lua`
- `functions/visual.lua`
- `functions/http.lua`
- `disk.lua`
- `keybindings.lua`
- `plugins/enabled/ai.lua`
- `plugins/enabled/git.lua`
- `plugins/enabled/ui.lua`
- `plugins/helpers/diagline.lua`
- `ui/statusline.lua`
- `ui/tabline.lua`

Transformation rule: lowercase + `_` → `-`. Examples:
- `"GRAY_3"` → `"gray-3"`
- `"DARK_GREEN"` → `"dark-green"`
- `"GIT_BRANCH"` → `"git-branch"`
- `"WHITE"` → `"white"`

**Note:** Only color name strings are transformed — not Lua variable names, highlight group names, or other strings that happen to be uppercase.

## No tests

Per project policy, no Lua test framework. Verify manually by opening NeoVim and confirming colors render correctly.

## Acceptance criteria

- [ ] `colorscheme/init.lua` stores keys directly as kebab-case (no `UPPERCASE_SNAKE` conversion)
- [ ] No `"UPPERCASE_SNAKE"` color strings remain in any Lua file
- [ ] No dot-notation `O.colors.env.UPPERCASE` accesses remain
- [ ] NeoVim renders colors correctly (manual verification)
