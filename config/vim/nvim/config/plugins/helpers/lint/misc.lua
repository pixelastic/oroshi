local M = {}

-- Returns the diag data (lineNumber, windowId, bufferId)
M.getDiagData = function()
  local windowId = F.windowId()
  if not O.diagnostics[windowId] then
    O.diagnostics[windowId] = {}
  end
  return O.diagnostics[windowId]
end

return M
