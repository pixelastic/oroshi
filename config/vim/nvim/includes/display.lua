-- TEXT WRAPPING
vim.opt.wrap = false       -- Do not wrap text by default
vim.opt.textwidth = 80     -- Expected max length
vim.opt.colorcolumn = "81"   -- Visual clue
vim.opt.sidescrolloff = 15 -- Display 15 chars right and left of cursor
vim.opt.linebreak = true   -- Wrap at words, not in the middle of them
vim.opt.showbreak = '↪ '   -- Character to use to prefix wrapped lines

-- LINE NUMBER
vim.opt.number = true       -- Display line numbers
vim.opt.signcolumn = "yes"  -- Always display sign
vim.opt.cursorline = true   -- Highlight current line
vim.opt.scrolloff = 999     -- Keep current line as centered as possible

-- INDENTATION
vim.opt.shiftwidth = 2 -- Indent by 2 spaces
vim.opt.tabstop = 2 -- Tab displayed as 2 spaces
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when creating a new one

-- COLOR
vim.opt.background = "dark"     -- Prefer dark mode
-- vim.cmd("colorscheme oroshi")  -- Use oroshi colorscheme
vim.cmd("colorscheme irisho")  -- Use oroshi colorscheme
