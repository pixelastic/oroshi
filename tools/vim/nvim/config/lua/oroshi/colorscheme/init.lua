-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.opt.background = "dark" -- Prefer dark mode
vim.g.colors_name = "oroshi"

-- Clear all highlights
vim.cmd("highlight clear")
if vim.g.syntax_on then
  vim.cmd("syntax reset")
end

-- Load all colors from dist/colors.json
-- Keys in JSON are kebab-case; Lua colorscheme uses UPPERCASE_SNAKE
local distPath = vim.env.OROSHI_ROOT .. "/tools/term/zsh/config/theming/dist/colors.json"
local colorsJson = F.readJson(distPath) or {}
O.colors.env = {}
for name, entry in pairs(colorsJson) do
  local luaKey = name:upper():gsub("-", "_")
  O.colors.env[luaKey] = entry.hex
end

O_require("oroshi/colorscheme/ui") -- Tabline, statusline, split, etc
O_require("oroshi/colorscheme/syntax") -- Syntax highlight
O_require("oroshi/colorscheme/unused") -- List of known Highlight groups not yet used

-- Initialize filetype-specific highlight system
F.initFiletypeSpecificHighlights()
