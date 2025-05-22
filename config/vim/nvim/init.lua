-- TODO: Align on antything
-- TODO: statusline to show the mode
-- TODO: Linters linters
-- TODO: Rewrite colorscheme in lua
-- TODO: Make sure kitty.conf is correctly highlighted
-- TODO: Find a plugin that can autoclose functions
-- TODO: Completion
-- TODO: See what to do with backup and swap
-- TODO: Find what works and what does not in a macro
-- TODO: Add colored line numbers based on if add/delete/modified

-- Functions
require('oroshi/functions')

-- Config
require('oroshi/clipboard')
require('oroshi/completion')
require('oroshi/disk')
require('oroshi/display')
require('oroshi/filetypes')
require('oroshi/folding')
require('oroshi/keybindings')
require('oroshi/search')
require('oroshi/sessions')
require('oroshi/statusline')
require('oroshi/tabline')

-- Plugins
require('oroshi/lazy')


