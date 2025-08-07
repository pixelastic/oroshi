local autocmd = F.autocmd
local diagline = O_require('oroshi/plugins/helpers/diagline')
local M = {}

-- Configure the statusline to listen to LSP loading
M.init = function()
  -- Update the statusline when LSP is loading
  autocmd('LspProgress', function()
    local bufferId = F.bufferId()
    local currentStatus = O.statusline.lsp['buf'..bufferId]

    -- Stop early if somehow the buffer already has a LSP statusline status
    -- saved.
    if currentStatus then
      return
    end

    O.statusline.lsp['buf'..bufferId] = 'loading'

    vim.cmd("redrawstatus")
  end, { pattern = 'begin'})

  -- Update statusbar when LSP is updated
  autocmd('DiagnosticChanged', function()
    -- Find errors in that buffer
    local bufferId = F.bufferId()
    local errors = vim.diagnostic.get(bufferId)

    -- Update the statusbar status
    local severity = M.getHighestSeverity(errors)
    O.statusline.lsp['buf'..bufferId] = severity

    -- Hide the diag line if everything is clean
    if severity == 'success' then
      diagline.hide(diagline.getDiagData())
    end

    vim.cmd("redrawstatus")
  end)
end

M.getHighestSeverity = function(diagnostics)
  local current = 5
  for _, diag in ipairs(diagnostics) do
    if diag.severity < current then
      current = diag.severity
    end
  end
  return M.severityIntToString(current)
end

M.severityIntToString = function(severityInt)
  local severities = {
    [1] = 'error',
    [2] = 'warning',
    [3] = 'info',
    [4] = 'hint',
    [5] = 'success',
  }
  return severities[severityInt];
end


return M
