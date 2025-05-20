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
-- TODO: Toggle display of hidden chars
-- TODO: Align on comma
-- TODO: Allow folding
-- Maybe make nvim-tree verylazy so it is only loaded when I press the keymap?
--    And jave the keymap defined as part of lazy.vim

-- TODO: statusline to show the mode
-- Run linters
-- Debug colorscheme

-- TODO: Highlight TODO

-- TOOD: Kitty conf highlight

-- Functions
require('oroshi/functions')

-- Config
require('oroshi/clipboard')
require('oroshi/display')
require('oroshi/filetypes')
require('oroshi/keybindings')
require('oroshi/tabline')
require('oroshi/sessions')
require('oroshi/disk')

-- Plugins
require('oroshi/lazy')


