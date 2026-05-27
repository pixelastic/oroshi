local M = {}

M.onInit = function()
  -- Set filetype for config files
  F.ftset("*gitconfig", "gitconfig")
  F.ftset("*.conf", "ini")
end

return M
