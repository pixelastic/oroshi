-- undo
vim.opt.undofile = true -- Save undos in a file
vim.opt.undodir = vim.fs.normalize("~/.config/nvim/undo/") -- Where to save the undo files
vim.opt.undolevels = 1000 -- Number of undos to save

-- views
vim.opt.viewdir = vim.fs.normalize("~/.config/nvim/view") -- Where to save views
vim.opt.viewoptions = "cursor,folds" -- What to save in views
-- Functions
local function saveView()
  -- Stop on buffers we specifically marked as not needing a view
  if vim.b.oroshi_disable_view then
    return
  end

  vim.cmd("mkview 1")
end
local function loadView()
  -- Stop on buffers we specifically marked as not needing a view
  if vim.b.oroshi_disable_view then
    return
  end

  -- silent! is used to supress errors on first opening, as there is no view
  -- loaded yet
  vim.cmd('silent! loadview 1') 
  vim.cmd('normal ^') -- Go to first character of the line
end
local function disableView()
  vim.b.oroshi_disable_view = true
end
-- Save
autocmd('BufLeave', '?*', saveView)
autocmd('BufWrite', '?*', saveView)
autocmd('VimLeavePre', '?*', saveView)
-- Load
autocmd('BufWinEnter', '?*', loadView)
-- Specific filetypes where we don't handle views
ftplugin('fzf', disableView)


