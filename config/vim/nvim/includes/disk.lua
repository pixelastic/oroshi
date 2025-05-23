vim.opt.swapfile = false
-- Working directory
-- Set it as the directory of the currently edited file
local function updateWorkingDirectory()
  local workingDirectory = vim.fn.expand('%:p:h')
  vim.cmd('lcd '.. vim.fn.fnameescape(workingDirectory))
end
autocmd('BufEnter', '*', updateWorkingDirectory)
