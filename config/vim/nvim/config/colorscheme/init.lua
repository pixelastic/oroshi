-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.opt.background = "dark"     -- Prefer dark mode
vim.g.colors_name = "oroshi"

-- Clear all highlights
vim.cmd('highlight clear')
if vim.g.syntax_on then
  vim.cmd('syntax reset')
end

-- getEnvColors: Returns the list of all colors defines in env
local function getEnvColors()
  local colors = {}

  local COLORS_INDEX = F.env('COLORS_INDEX')
  local items = vim.split(COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = F.replace(item, 'ALIAS_', '')
    local value = F.env('COLOR_' .. item .. '_HEXA')
    colors[key] = value
  end
  return colors
end

-- Save all color aliases from env
O.colors.env = getEnvColors()

O_require('oroshi/colorscheme/ui')      -- Tabline, statusline, split, etc
O_require('oroshi/colorscheme/syntax')  -- Syntax highlight
O_require('oroshi/colorscheme/unused')  -- List of known Highlight groups not yet used











