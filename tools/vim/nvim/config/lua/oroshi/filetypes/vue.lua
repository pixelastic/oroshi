local htmlHelper = O_require("oroshi/filetypes/html")
local M = {}

M.onFiletype = function()
  F.imap("<C-E>", htmlHelper.expandEmmet, "Expand Emmet abbreviation")
end

return M
