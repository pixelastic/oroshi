vim.opt.autowrite = true -- Save file when switching tabs
vim.opt.autoread = true -- Update file if changed from outside
vim.opt.swapfile = false
vim.opt.backup = false -- no file~ leftovers
vim.opt.writebackup = false -- no copy/save/delete operations


-- Working directory
-- Set it as the directory of the currently edited file
local function updateWorkingDirectory()
  local workingDirectory = vim.fn.expand('%:p:h')
  vim.cmd('lcd '.. vim.fn.fnameescape(workingDirectory))
end
autocmd('BufEnter', '*', updateWorkingDirectory)
