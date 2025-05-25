-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.opt.background = "dark"     -- Prefer dark mode
vim.g.colors_name = "oroshi"

-- Keybindings {{{

-- F3: Debug colors
local function debugColors()
  withReadableMsgArea(function()
    vim.show_pos()
  end)
end
nmap('<F3>', debugColors, 'Display highlight groups')
imap('<F3>', debugColors, 'Display highlight groups')

-- CTRL-X: Change XXX into YYY
-- Easy way to toggle XXX placeholders into YYY placeholders, to more easily
-- identify what a specific highlight group refers to
local function visualTogglePlaceholders(from, to)
  local function changeSelection(from, to)
    __.hack_ensureVisualSelection()
    vim.cmd("silent! '<,'>s/" .. from .. "/" .. to)
    vim.cmd('normal gv')
  end

  changeSelection('XXX', 'ZZZ')
  changeSelection('YYY', 'XXX')
  changeSelection('ZZZ', 'YYY')

  -- Go back to normal mode and save
  vim.api.nvim_command('normal ') -- <Esc> to leave visual mode
  vim.cmd('silent! w!')
end
local function normalTogglePlaceholders()
  vim.cmd('normal V')
  visualTogglePlaceholders()
end
vmap('<C-X>', visualTogglePlaceholders, 'Replace YYY with XXX')
nmap('<C-X>', normalTogglePlaceholders, 'Replace YYY with XXX')
-- }}}

-- Clear all highlights
vim.cmd('highlight clear')
if vim.g.syntax_on then
  vim.cmd('syntax reset')
end

frequire('oroshi/colorscheme/ui') -- Tabline, statusline, split, etc
frequire('oroshi/colorscheme/editing') -- Normal, visual, fold
frequire('oroshi/colorscheme/syntax')  -- Syntax highlight
frequire('oroshi/colorscheme/unused') -- List of known Highlight groups not yet used












