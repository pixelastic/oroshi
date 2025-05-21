vim.g.mapleader = "," -- Leader key

-- Capslock
-- Switch between Normal and Insert mode
imap("<F13>", "<Esc>l", "Insert  => Normal")
nmap("<F13>", "i", "Normal  => Insert")
vmap("<F13>", "<Esc>", "Visual  => Normal")
cmap("<F13>", "<Esc>", "Command => Normal")

-- Space
nmap('<Space>', '.', 'Repeat', { remap = true })


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




-- F1: Show help
nmap('<F1>', 'K', 'Show help of word under cursor')


-- Tabs
nmap('<C-H>', 'gT', 'Previous tab')
imap('<C-H>', '<Esc>gT', 'Previous tab')
nmap('<C-L>', 'gt', 'Next tab')
imap('<C-L>', '<Esc>gt', 'Next tab')
nmap(',t', ':tabedit<Space>', 'Open file in new tab', { silent = false })

-- Splits
nmap('<C-Up>', '<C-W>k', 'Go to split up')
nmap('<C-Right>', '<C-W>l', 'Go to split right')
nmap('<C-Down>', '<C-W>j', 'Go to split bottom')
nmap('<C-Left>', '<C-W>h', 'Go to split left')




-- Move in a grid
nmap('j', 'gj', 'Move to the char below')
vmap('j', 'gj', 'Move to the char below')
nmap('k', 'gk', 'Move to the char up')
vmap('k', 'gk', 'Move to the char up')

-- Start / End of line
nmap("H", "^", "Start of line")
vmap("H", "^", "Start of line")
nmap("L", "g_", "End of line")
vmap("H", "g_", "Start of line")

-- Scroll one page at a time
nmap('U', '<C-U>', 'Scroll up one page')
vmap('U', '<C-U>', 'Scroll up one page')
nmap('D', '<C-D>', 'Scroll down one page')
vmap('D', '<C-D>', 'Scroll down one page')

-- Indent / Dedent
nmap('<Tab>', '>>ll', 'Indent line')
vmap('<Tab>', '>gv', 'Indent selection')
imap('<S-Tab>', '<Esc><<hi', 'Dedent line')
nmap('<S-Tab>', '<<hh', 'Dedent line')
vmap('<S-Tab>', '<gv', 'Dedent selection')

-- Increment / Decrement numbers
nmap('<C-J>', '<C-X>', 'Increment number under cursor')
nmap('<C-K>', '<C-A>', 'Decrement number under cursor')

-- Add semicolon
local function addSemicolonAtEndOfLine()
  local currentLine = vim.api.nvim_get_current_line();
  local lastChar = currentLine:sub(-1)

  if lastChar == ';' then
    return
  end

  vim.api.nvim_set_current_line(currentLine .. ';')
end
nmap(';', addSemicolonAtEndOfLine, 'Add a semicolon at end of line')

-- Paste
nmap('gp', '`[v`]', "Select what was just pasted")
nmap('c', '"_c', "Change without copying it")
vmap('x', '"_x', "Delete without copying it")





-- Sort, Shuffle, Uniq 
vmap("r", ":!shuf<CR>", "Randomize")
vmap("s", ":!sort --version-sort<CR>", "Sort")
vmap("S", ":!sort --version-sort --reverse<CR>", "Sort")
vmap("u", ":sort u<CR>", "Remove duplicates")
vmap("n", ":!cat -n<CR>", "Number lines")
vmap("L", ":!sort-by-length<CR>", "Sort by length")
