-- auto-read {{{
-- Update files, even if changed from outside
vim.opt.autoread = true
-- }}}

-- auto-save {{{
-- Auto-save as often as possible
local function saveBufferWhenLeavingTab()
  if not vim.bo.modified      then return end -- Stop if not modified
  if vim.bo.buftype ~= ""     then return end -- Stop if not a regular buffer (help, quickfix, etc)
  if not vim.bo.modifiable    then return end -- Stop if not modifiable
  if vim.bo.readonly          then return end -- Stop if readonly on disk
  if vim.fn.expand("%") == "" then return end -- Stop if has no name

  vim.cmd("silent! write")
end
autocmd('TabLeave', '*', saveBufferWhenLeavingTab)
-- }}}

-- backup {{{
-- Do not save backup files on disk, nor temporary when saving on disk
vim.opt.backup      = false -- no file~ leftovers
vim.opt.writebackup = false -- do not create a temporary file when writing to disk
-- }}}

-- clipboard {{{
-- Share clipboard with the OS
vim.opt.clipboard = "unnamedplus" -- Use the global clipboard
-- }}}

-- swap {{{
-- Write current changes to a swap file, in a shared directory, to restore in
-- case of crash
vim.opt.swapfile  = true
vim.opt.directory = vim.fs.normalize("~/.config/nvim/swap/") .. '//' -- Where to save the swap files (// uses full paths with %)
vim.opt.shortmess:append('A') -- Prevent error message when opening twice the same file
-- }}}

-- undos {{{
-- Save undos across sessions
vim.opt.undofile   = true                                     -- Save undos in a file
vim.opt.undolevels = 1000                                     -- Number of undos to save
vim.opt.undodir    = vim.fs.normalize("~/.config/nvim/undo/") -- Where to save the undo files
-- }}}

-- views {{{
-- Save local config like cursor position and folds across sessions
vim.opt.viewdir     = vim.fs.normalize("~/.config/nvim/view") -- Where to save views
vim.opt.viewoptions = "cursor,folds"                          -- What to save in views
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
autocmd('BufWinEnter', '?*', loadView)                              -- Load

-- Specific filetypes where we don't handle views
local function disableView()
  vim.b.oroshi_disable_view = true
end
ftplugin('fzf', disableView)
-- }}}

-- working directory {{{
-- Set it as the directory of the currently edited file
local function updateWorkingDirectory()
  local workingDirectory = vim.fn.expand('%:p:h')
  vim.cmd('lcd '.. vim.fn.fnameescape(workingDirectory))
end
autocmd('BufEnter', '*', updateWorkingDirectory)
-- }}}
