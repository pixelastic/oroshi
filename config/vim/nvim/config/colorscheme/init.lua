-- Name:         Oroshi
-- Maintainer:   Tim Carry <tim@pixelastic.com>
-- "C'est parce qu'il y a 6 matières, c'est ca ?"
-- "J'ai un coude chaud."

vim.opt.background = "dark"     -- Prefer dark mode
vim.g.colors_name = "oroshi"

-- Keybindings {{{


-- Clear all highlights
vim.cmd('highlight clear')
if vim.g.syntax_on then
  vim.cmd('syntax reset')
end

frequire('oroshi/colorscheme/ui') -- Tabline, statusline, split, etc
frequire('oroshi/colorscheme/syntax')  -- Syntax highlight
frequire('oroshi/colorscheme/unused') -- List of known Highlight groups not yet used












