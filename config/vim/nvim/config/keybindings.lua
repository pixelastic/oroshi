local nmap = F.nmap
local imap = F.imap
local vmap = F.vmap
local cmap = F.cmap
local ccmpmap = F.ccmpmap

vim.g.mapleader = "," -- Leader key
vim.g.timeoutlen = 300 -- Delay between keys in keybindings

-- Capslock
-- Switch between Normal and Insert mode
imap("<F13>", "<Esc>l", "Insert  => Normal")
nmap("<F13>", F.insertMode, "Normal  => Insert")
vmap("<F13>", "<Esc>", "Visual  => Normal")
cmap("<F13>", "<C-C>", "Command => Normal")

-- Space
nmap("<Space>", ".", "Repeat", { remap = true })

-- CTRL + A
nmap("<C-A>", "GVgg", "Select everything")
vmap("<C-A>", "<ESC>GVgg", "Select everything")
imap("<C-A>", "<ESC>GVgg", "Select everything")

-- CTRL + S
-- silent! is for not displaying a message that the file is saved
imap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")
nmap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")
vmap("<C-S>", "<CMD>silent! w<CR><ESC>", "Save file")

-- CTRL + D
local function saveAndQuit()
  local currentTabId = F.tabId()

  -- Save and close the current split
  F.saveBuffer()
  F.closeSplit()

  -- Stop if it moved us to another tab because it was the last one
  if F.tabId() ~= currentTabId then
    return
  end

  -- Check if the splits we have left contain interesting data
  local uiFiletypes = { "noice", "help", "qf", "NvimTree" }
  local hasImportantSplits = false
  F.forEachSplit(function(splitId)
    local bufferId = F.bufferId(splitId)
    local filetype = F.bufferOption("filetype", bufferId)

    if not F.includes(uiFiletypes, filetype) then
      hasImportantSplits = true
    end
  end)

  -- We still have important files open, we stop
  if hasImportantSplits then
    return
  end

  -- We only have UI splits, we close the tab
  F.closeTab()
end
imap("<C-D>", saveAndQuit, "Save file and quit")
nmap("<C-D>", saveAndQuit, "Save file and quit")
vmap("<C-D>", saveAndQuit, "Save file and quit")

local function ctrlfdebug() end
nmap("<C-F>", ctrlfdebug, "debug")

-- CTRL + N
nmap("<C-N>", ":tabedit<Space>", "Create new file in directory", { silent = false })

-- CTRL-X: Change XXX into YYY and vice-versa
local function togglePlaceholders()
  local selection = F.getSelection()
  for i, line in ipairs(selection) do
    line = F.replace(line, "XXX", "ZZZ")
    line = F.replace(line, "YYY", "XXX")
    line = F.replace(line, "ZZZ", "YYY")
    selection[i] = line
  end
  F.replaceSelection(selection)
end
local function selectLineAndTogglePlaceholders()
  F.selectLine()
  togglePlaceholders()
end
vmap("<C-X>", togglePlaceholders, "Replace YYY with XXX")
nmap("<C-X>", selectLineAndTogglePlaceholders, "Replace YYY with XXX")
-- }}}

-- F1: Show help
nmap("<F1>", "K", "Show help of word under cursor")

-- F2: Reload colorscheme
local function reloadColorscheme()
  O_require("oroshi/colorscheme")
end
nmap("<F2>", reloadColorscheme, "Reload oroshi colorscheme")
imap("<F2>", reloadColorscheme, "Reload oroshi colorscheme")
vmap("<F2>", reloadColorscheme, "Reload oroshi colorscheme")
cmap("<F2>", reloadColorscheme, "Reload oroshi colorscheme")

-- C-F2: Reload full config
local function reloadConfig()
  O_require("oroshi/index")
end
nmap("<F26>", reloadConfig, "Reload nvim config") -- <F26> is Ctrl-F2
imap("<F26>", reloadConfig, "Reload nvim config")
vmap("<F26>", reloadConfig, "Reload nvim config")
cmap("<F26>", reloadConfig, "Reload nvim config")

-- F3: Debug colors
nmap("<F3>", F.debugColors, "Display highlight groups")
imap("<F3>", F.debugColors, "Display highlight groups")

-- Tabs
-- Switch
nmap("<C-H>", "gT", "Previous tab")
imap("<C-H>", "<Esc>gT", "Previous tab")
nmap("<C-L>", "gt", "Next tab")
imap("<C-L>", "<Esc>gt", "Next tab")
-- Change position
nmap("Ⓗ", "<CMD>-tabmove<CR>", "Move tab to the left")
imap("Ⓗ", "<CMD>-tabmove<CR>", "Move tab to the left")
nmap("Ⓛ", "<CMD>+tabmove<CR>", "Move tab to the right")
imap("Ⓛ", "<CMD>+tabmove<CR>", "Move tab to the right")
-- Open file in new tab
nmap(",t", ":tabedit<Space>", "Open file in new tab", { silent = false })

-- Splits
-- Move with Ctrl-Arrows
nmap("<C-Up>", "<C-W>k", "Go to split up")
nmap("<C-Right>", "<C-W>l", "Go to split right")
nmap("<C-Down>", "<C-W>j", "Go to split bottom")
nmap("<C-Left>", "<C-W>h", "Go to split left")
imap("<C-Up>", "<Esc><C-W>k", "Go to split up")
imap("<C-Right>", "<Esc><C-W>l", "Go to split right")
imap("<C-Down>", "<Esc><C-W>j", "Go to split bottom")
imap("<C-Left>", "<Esc><C-W>h", "Go to split left")
-- Iterate through splits
nmap("<C-U>", "<C-W>w", "Go to next split")
imap("<C-U>", "<Esc><C-W>w", "Go to next split")

-- Completion
ccmpmap("<CR>", "<C-y> ", "Accept suggestion")
ccmpmap("<Down>", "<C-n>", "Next suggestion")
ccmpmap("<Up>", "<C-p>", "Previous suggestion")
ccmpmap("<C-c>", "<C-e>", "Cancel suggestions")

-- Help
nmap("?", ":help ", "Show help", { silent = false })

-- Move in a grid
nmap("j", "gj", "Move to the char below")
vmap("j", "gj", "Move to the char below")
nmap("k", "gk", "Move to the char up")
vmap("k", "gk", "Move to the char up")

-- Start / End of line
nmap("H", "^", "Start of line")
vmap("H", "^", "Start of line")
nmap("L", "g_", "End of line")
vmap("H", "g_", "Start of line")

-- Scroll half a page at a time
nmap("U", "22k", "Scroll up one half page")
vmap("U", "22k", "Scroll up one half page")
nmap("D", "22j", "Scroll down one half page")
vmap("D", "22j", "Scroll down one half page")

-- Tab (Indent or Completion)
local function indentOrComplete()
  local copilot = require("copilot.suggestion")

  -- Complete Copilot suggestion
  if copilot.is_visible() then
    copilot.accept()
    return
  end

  -- No Copilot suggestion, insert a tab for indentation
  F.sendKey("<Tab>")
end
imap("<Tab>", indentOrComplete, "Accept Copilot suggestion or indent")
-- In normal and visual, always indent
nmap("<Tab>", ">>ll", "Indent line")
vmap("<Tab>", ">gv", "Indent selection")

-- Shift-Tab: dedent
imap("<S-Tab>", "<Esc><<hi", "Dedent line")
nmap("<S-Tab>", "<<hh", "Dedent line")
vmap("<S-Tab>", "<gv", "Dedent selection")

-- Increment / Decrement numbers
nmap("<C-J>", "<C-X>", "Increment number under cursor")
nmap("<C-K>", "<C-A>", "Decrement number under cursor")

-- Add semicolon
local function addSemicolonAtEndOfLine()
  local currentLine = F.line()
  local lastChar = currentLine:sub(-1)

  if lastChar == ";" then
    return
  end

  F.updateLine(currentLine .. ";")
end
nmap(";", addSemicolonAtEndOfLine, "Add a semicolon at end of line")

-- Paste
nmap("P", ":pu!", "Paste right before current line")
vmap("p", '"_x:pu', "Paste in place of current selection")
nmap("gp", "`[v`]", "Select what was just pasted")
nmap("c", '"_c', "Change without copying it")
nmap("x", '"_x', "Delete without copying it")
vmap("x", '"_x', "Delete without copying it")

-- Marks and jump
nmap("⒨", "`m", "Jump to mark set with mm") -- Ctrl-M jumps to m mark
nmap("M", "`", "Jump to specific mark")

-- Sort, Shuffle, Uniq
vmap("r", ":!shuf<CR><CR>", "Randomize")
vmap("s", ":!sort --version-sort<CR><CR>", "Sort")
vmap("S", ":!sort --version-sort --reverse<CR><CR>", "Sort", { silent = false })
vmap("u", ":sort u<CR>", "Remove duplicates")
vmap("n", ":!cat -n<CR><CR>", "Number lines")
vmap("L", ":!sort-by-length<CR><CR>", "Sort by length")
