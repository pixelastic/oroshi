local M = {}

M.onFiletype = function()
  local bufferId = F.bufferId()
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = bufferId })
end

return M
