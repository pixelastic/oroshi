vim.opt.clipboard = "unnamedplus" -- Use the global clipboard
vim.opt.autowrite = true -- Save file when switching tabs
vim.opt.autoread = true -- Update file if changed from outside
vim.opt.swapfile = false

-- backup
vim.opt.backup = false -- no file~ leftovers
vim.opt.writebackup = false -- no copy/save/delete operations

-- undos
vim.opt.undofile = true -- Save undos in a file
vim.opt.undodir = vim.fs.normalize("~/.config/nvim/undo/") -- Where to save the undo files
vim.opt.undolevels = 1000 -- Number of undos to save


-- views
vim.opt.viewdir = vim.fs.normalize("~/.config/nvim/view") -- Where to save views
vim.opt.viewoptions = "cursor,folds" -- What to save in views
local function saveView()
  -- Stop on buffers we specifically marked as not needing a view
  if vim.b.oroshi_disable_view then return end

  vim.cmd("mkview 1")
end
local function loadView()
  -- Stop on buffers we specifically marked as not needing a view
  if vim.b.oroshi_disable_view then return end

  -- silent! is used to supress errors on first opening, as there is no view
  -- loaded yet
  vim.cmd('silent! loadview 1')
  vim.cmd('normal ^') -- Go to first character of the line
end
autocmd( { 'BufLeave', 'BufWrite', 'VimLeavePre' }, '?*', saveView) -- Save
autocmd('BufWinEnter', '?*', loadView) -- Load

-- Specific filetypes where we don't handle views
local function disableView()
  vim.b.oroshi_disable_view = true
end
ftplugin('fzf', disableView)

-- Working directory {{{
-- Set it as the directory of the currently edited file
local function updateWorkingDirectory()
  local workingDirectory = vim.fn.expand('%:p:h')
  vim.cmd('lcd '.. vim.fn.fnameescape(workingDirectory))
end
autocmd('BufEnter', '*', updateWorkingDirectory)
-- }}}
