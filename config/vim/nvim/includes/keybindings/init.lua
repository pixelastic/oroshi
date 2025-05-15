-- Leader key
vim.g.mapleader = ","

-- Mapping functions {{{
function map(mode, input, output, description)
  vim.keymap.set(mode, input, output, { desc = description, silent = true, noremap = true })
end
function imap(input, output, description)
  map("i", input, output, description)
end
function nmap(input, output, description)
  map("n", input, output, description)
end
function vmap(input, output, description)
  map("v", input, output, description)
end
function cmap(input, output, description)
  map("c", input, output, description)
end
--- }}}

require('oroshi.keybindings.capslock')
require('oroshi.keybindings.ctrl-d')
require('oroshi.keybindings.ctrl-s')
require('oroshi.keybindings.enter')
require('oroshi.keybindings.movement')
require('oroshi.keybindings.selection')
require('oroshi.keybindings.space')
