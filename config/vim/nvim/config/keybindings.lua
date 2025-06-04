vim.g.mapleader = ","  -- Leader key
vim.g.timeoutlen = 300 -- Delay between keys in keybindings

-- Capslock
-- Switch between Normal and Insert mode
imap("<F13>", "<Esc>l",            "Insert  => Normal")
nmap("<F13>", vim.cmd.startinsert, "Normal  => Insert")
vmap("<F13>", "<Esc>",             "Visual  => Normal")
cmap("<F13>", "<C-C>",             "Command => Normal")

-- Space
nmap('<Space>', '.', 'Repeat', { remap = true })


-- CTRL + A
nmap('<C-A>', 'GVgg',      'Select everything')
vmap('<C-A>', '<ESC>GVgg', 'Select everything')
imap('<C-A>', '<ESC>GVgg', 'Select everything')

-- CTRL + S
-- silent! is for not displaying a message that the file is saved
imap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")
nmap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")
vmap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")

-- CTRL + D
local function saveAndQuit()
  -- If the file has no name, we simply quit
  if __.isNoName() then
    vim.cmd('q!')
    return
  end
  -- Otherwise, we save and quit
  vim.cmd('x')
end
imap("<C-D>", saveAndQuit, "Save file and quit")
nmap("<C-D>", saveAndQuit, "Save file and quit")
vmap("<C-D>", saveAndQuit, "Save file and quit")

-- CTRL + N
nmap("<C-N>", ":tabedit<Space>", "Create new file in directory", { silent = false })

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



-- F1: Show help
nmap('<F1>', 'K', 'Show help of word under cursor')

-- F2: Reload
local function reloadConfig()
  frequire('oroshi/index')
  __.debug('Config reloaded')
end
nmap('<F2>', reloadConfig, 'Reload nvim config')
imap('<F2>', reloadConfig, 'Reload nvim config')
vmap('<F2>', reloadConfig, 'Reload nvim config')
cmap('<F2>', reloadConfig, 'Reload nvim config')

-- F3: Debug colors
local function debugColors()
  __.commandline.withReadableMsgArea(function()
    vim.show_pos()
  end)
end
nmap('<F3>', debugColors, 'Display highlight groups')
imap('<F3>', debugColors, 'Display highlight groups')

-- Tabs
-- Switch
nmap('<C-H>', 'gT',      'Previous tab')
imap('<C-H>', '<Esc>gT', 'Previous tab')
nmap('<C-L>', 'gt',      'Next tab')
imap('<C-L>', '<Esc>gt', 'Next tab')
-- Change position
nmap('Ⓗ', '<CMD>-tabmove<CR>', 'Move tab to the left')
imap('Ⓗ', '<CMD>-tabmove<CR>', 'Move tab to the left')
nmap('Ⓛ', '<CMD>+tabmove<CR>', 'Move tab to the right')
imap('Ⓛ', '<CMD>+tabmove<CR>', 'Move tab to the right')
-- Open file in new tab
nmap(',t', ':tabedit<Space>', 'Open file in new tab', { silent = false })



-- Splits
nmap('<C-Up>',    '<C-W>k', 'Go to split up')
nmap('<C-Right>', '<C-W>l', 'Go to split right')
nmap('<C-Down>',  '<C-W>j', 'Go to split bottom')
nmap('<C-Left>',  '<C-W>h', 'Go to split left')


-- Completion
ccmpmap('<CR>',   '<C-y> ', 'Accept suggestion')
ccmpmap('<Down>', '<C-n>',  'Next suggestion')
ccmpmap('<Up>',   '<C-p>',  'Previous suggestion')
ccmpmap('<C-c>',  '<C-e>',  'Cancel suggestions')


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

-- Scroll half a page at a time
nmap('U', '22k', 'Scroll up one half page')
vmap('U', '22k', 'Scroll up one half page')
nmap('D', '22j', 'Scroll down one half page')
vmap('D', '22j', 'Scroll down one half page')

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
  local currentLine = __.currentLine()
  local lastChar = currentLine:sub(-1)

  if lastChar == ';' then
    return
  end

  __.currentLine(currentLine .. ';')
end
nmap(';', addSemicolonAtEndOfLine, 'Add a semicolon at end of line')

-- Paste
nmap('p', ':pu<CR>`[=`]', "Paste right after current line, and keep indent")
nmap('P', ':pu!<CR>`[=`]', "Paste right before current line, and keep indent")
nmap('gp', '`[v`]', "Select what was just pasted")
nmap('c', '"_c', "Change without copying it")
nmap('x', '"_x', "Delete without copying it")
vmap('x', '"_x', "Delete without copying it")

-- Marks and jump
nmap('⒨', "`m", "Jump to mark set with mm") -- Ctrl-M jumps to m mark
nmap('M', '`', 'Jump to specific mark')

-- Sort, Shuffle, Uniq 
vmap("r", ":!shuf<CR><CR>", "Randomize")
vmap("s", ":!sort --version-sort<CR><CR>", "Sort")
vmap("S", ":!sort --version-sort --reverse<CR><CR>", "Sort", { silent = false })
vmap("u", ":sort u<CR>", "Remove duplicates")
vmap("n", ":!cat -n<CR><CR>", "Number lines")
vmap("L", ":!sort-by-length<CR><CR>", "Sort by length")
