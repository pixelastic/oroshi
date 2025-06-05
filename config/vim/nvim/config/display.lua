local nmap = F.nmap
local imap = F.imap
local autocmd = F.autocmd

-- TEXT WRAPPING
vim.opt.wrap          = false      -- Do not wrap text by default
vim.opt.textwidth     = 80         -- Expected max length
vim.opt.colorcolumn   = "81"       -- Visual clue
vim.opt.sidescrolloff = 15         -- Display 15 chars right and left of cursor
vim.opt.linebreak     = true       -- Wrap at words, not in the middle of them
vim.opt.showbreak     = '↪ '       -- Character to use to prefix wrapped lines

-- LINE NUMBER
vim.opt.number      = true    -- Display line numbers
vim.opt.numberwidth = 3       -- Use 3 cells, allow for a padding left and right
vim.opt.signcolumn  = "auto"  -- display signs if any
vim.opt.cursorline  = true    -- Highlight current line
vim.opt.scrolloff   = 22      -- Keep 22 lines above and below (centering the display)

-- INDENTATION
vim.opt.shiftwidth = 2    -- Indent by 2 spaces
vim.opt.tabstop    = 2    -- Tab displayed as 2 spaces
vim.opt.expandtab  = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when creating a new one

-- HIDDEN CHARACTERS {{{
local useDefaultListchars = true
local defaultListchars = {
  -- Only non-breakable spaces, trailing spaces, multispaces and scroll markers
  nbsp = "∅", trail = "", precedes = "", extends = "", 
  lead = " ", multispace = " ", tab = "  ", eol = ' '
}
-- Also end of lines, tabs and leading spaces
local extendedListchars = {
  nbsp = "∅", trail = "", precedes = "", extends = "", 
  lead = "", multispace = "", tab = "  ", eol = '↲'
}
vim.opt.list = true
vim.opt.listchars = defaultListchars
function toggleListchars()
  -- Swap between default and extended
  vim.opt.listchars = useDefaultListchars and extendedListchars or defaultListchars
  -- Change the current mode
  useDefaultListchars = not useDefaultListchars
end
nmap('<F8>', toggleListchars, 'Toggle more or less hidden characters')
imap('<F8>', toggleListchars, 'Toggle more or less hidden characters')
-- }}}

-- Unfocused splits
local function disableCursorLine()
  vim.opt_local.cursorline = false
end
local function enableCursorLine()
  vim.opt_local.cursorline = true
end
autocmd({'WinLeave', 'FocusLost' },  disableCursorLine) -- Disable current line highlight when out of focus
autocmd({'WinEnter', 'FocusGained' },  enableCursorLine) -- Re-enable current line hightlight when back in focus
