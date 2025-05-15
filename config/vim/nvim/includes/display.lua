-- TEXT WRAPPING
vim.opt.wrap = false       -- Do not wrap text
vim.opt.textwidth = 80     -- Expected max length
vim.opt.colorcolumn = "81"   -- Visual clue
vim.opt.sidescrolloff = 15 -- Display 15 chars right and left of cursor

-- LINE NUMBER
vim.opt.number = true       -- Display line numbers
vim.opt.signcolumn = "yes"  -- Always display sign
vim.opt.cursorline = true   -- Highlight current line

-- COLOR
vim.opt.background = "dark"     -- Prefer dark mode
vim.cmd [[colorscheme oroshi]]  -- Use oroshi colorscheme
