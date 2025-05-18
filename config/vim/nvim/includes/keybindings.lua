-- Leader key
vim.g.mapleader = ","


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
--
--

-- Mapping functions {{{
function map(mode, input, output, description, options)
  local defaults = { 
    silent = true, 
    noremap = true,
    desc = description, 
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})
  vim.keymap.set(mode, input, output, config)
end
function imap(input, output, description, options)
  map("i", input, output, description, options)
end
function nmap(input, output, description, options)
  map("n", input, output, description, options)
end
function vmap(input, output, description, options)
  map("v", input, output, description, options)
end
function cmap(input, output, description, options)
  map("c", input, output, description, options)
end
--- }}}

-- Capslock
-- Switch between Normal and Insert mode
imap("<F13>", "<Esc>l", "Insert  => Normal")
nmap("<F13>", "i", "Normal  => Insert")
vmap("<F13>", "<Esc>", "Visual  => Normal")
cmap("<F13>", "<Esc>", "Command => Normal")

-- Space
nmap('<Space>', '.', "Repeat")


-- CTRL + A
nmap('<C-A>', 'GVgg', 'Select everything')
vmap('<C-A>', '<ESC>GVgg', 'Select everything')
imap('<C-A>', '<ESC>GVgg', 'Select everything')

-- CTRL + S
imap("<C-S>", "<CMD>w<CR><ESC>", "Save file")
nmap("<C-S>", "<CMD>w<CR><ESC>", "Save file")
vmap("<C-S>", "<CMD>w<CR><ESC>", "Save file")

-- CTRL + D
imap("<C-D>", "<CMD>x<CR><ESC>", "Save file and quit")
nmap("<C-D>", "<CMD>x<CR><ESC>", "Save file and quit")
vmap("<C-D>", "<CMD>x<CR><ESC>", "Save file and quit")







-- Start / End of line
nmap("H", "^", "Start of line")
vmap("H", "^", "Start of line")
nmap("L", "g_", "End of line")
vmap("H", "g_", "Start of line")

-- Indent / Dedent
nmap('<Tab>', '>>^', 'Indent line')
vmap('<Tab>', '>gv', 'Indent selection')
nmap('<S-Tab>', '<<^', 'Dedent line')
vmap('<S-Tab>', '<gv', 'Dedent selection')





-- Sort, Shuffle, Uniq 
vmap("r", ":!shuf<CR>", "Randomize")
vmap("s", ":!sort --version-sort<CR>", "Sort")
vmap("u", ":sort u<CR>", "Remove duplicates")
