vim.opt.swapfile = false

-- TODO: Delete file keybinding
--  I can use eunuch to add the Delete/Remove (difference?) methods
--  But it will not close the current buffer, I need to manually close that
--  Also, I need to add the case where there is only one buffer left and we
--  delete it
--  in that case, I will need to close vim altogether.
--  I coded that in vimscript already, I should recode it in lua, but I will
--  need more tools in vim first
--
--
-- TODO: Surround to change the single to double quote
-- TODO: statusline to show the mode
-- TODO: Highlight TODO
-- TODO: Align on comma
-- TODO: Fuzzy search and various tabs
-- TODO: Allow folding
-- TODO: Toggle display of hidden chars
-- Remove which-key
-- Remove telescope
-- Run linters
-- Debug colorscheme
-- Help pages take full screen


-- Config
require('oroshi/clipboard')
require('oroshi/display')
require('oroshi/keybindings')
require('oroshi/filetypes')

-- Plugins
require('oroshi/lazy')


