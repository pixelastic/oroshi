local autocmd = F.autocmd
local M = {}

-- Configure the way diagnostics are displayed
M.init = function()
  M.configureDiagnostics()
  M.configureDiagLine()
end

-- Configure nvim diagnostic engine
M.configureDiagnostics = function()
  vim.diagnostic.config({
    update_in_insert = false, -- Do not pollute with warning in insert mode
    signs = {
      -- Display line numbers in color based on error type
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticLineNrError",
        [vim.diagnostic.severity.WARN] = "DiagnosticLineNrWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticLineNrInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticLineNrHint",
      },
    },
    -- Uncomment following lines to enable other display types
    -- virtual_text = { prefix = "█", current_line = true }, -- Virtual text
    -- virtual_lines = { current_line = true }, -- Virtual lines
  })
end

-- Configure the diag line displayed at the bottom
M.configureDiagLine = function()
  -- Update it whenever the cursor moves
  autocmd("CursorMoved", function()
    local data = M.getDiagData()
    local currentLineNumber = F.lineNumber()

    -- Same line: Do nothing
    if data.lineNumber == currentLineNumber then
      return
    end
    data.lineNumber = currentLineNumber -- Update current line

    -- No error: We hide
    local error = M.getErrorDetails(currentLineNumber)
    if not error then
      M.hide(data)
      return
    end

    -- Update content of the diag line
    M.update(data, error)
  end)

  -- Replace it at the bottom whenever we resize
  autocmd({ "VimResized", "BufEnter" }, function()
    local data = M.getDiagData()
    M.alignAtBottomOfScreen(data)
  end)
end

-- Create a (hidden) diag line, as a window at the bottom of the screen
M.create = function(data)
  local width = F.windowWidth()
  local height = F.windowHeight()

  -- Create a buffer
  data.bufferId = F.newBuffer()

  -- Put that buffer into a window
  data.windowId = vim.api.nvim_open_win(data.bufferId, false, {
    relative = "win",
    anchor = "SW",
    row = height,
    col = 0,
    width = width,
    height = 1,
    style = "minimal",
    focusable = false,
    hide = true,
  })
end

-- Hide the diag line
M.hide = function(data)
  if not data.windowId then
    return
  end

  vim.api.nvim_win_set_config(data.windowId, { hide = true })
end

-- Update the content of the diag line
M.update = function(data, error)
  if not data.windowId then
    M.create(data)
  end

  -- Update content
  local content = F.split(error.content, "\n")
  vim.api.nvim_buf_set_lines(
    data.bufferId, -- bufferId
    0,
    -1, -- Range, from beginning to end
    false, -- Do not error if adds more lines than previously
    content -- Actual content
  )

  -- Change highlight groups
  local severityToHighlight = {
    [vim.diagnostic.severity.ERROR] = "DiagnosticDiagLineError",
    [vim.diagnostic.severity.WARN] = "DiagnosticDiagLineWarn",
    [vim.diagnostic.severity.INFO] = "DiagnosticDiagLineInfo",
    [vim.diagnostic.severity.HINT] = "DiagnosticDiagLineHint",
  }
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:" .. severityToHighlight[error.severity],
    { win = data.windowId }
  )

  -- Show window
  M.alignAtBottomOfScreen(data)
end

M.alignAtBottomOfScreen = function(data)
  -- No-op if no diagline
  if not data.windowId then
    return
  end

  vim.api.nvim_win_set_config(data.windowId, {
    relative = "win",
    width = F.windowWidth(),
    row = F.windowHeight(),
    col = 0,
    hide = false,
  })
end

-- Returns the .severity and .content of the current line
M.getErrorDetails = function(lineNumber)
  local diag = vim.diagnostic.get(0, { lnum = lineNumber - 1 })

  if F.isEmpty(diag) then
    return nil
  end

  return {
    severity = diag[1].severity,
    content = diag[1].code .. " : " .. diag[1].message,
  }
end

-- Returns the diag data (lineNumber, windowId, bufferId)
M.getDiagData = function()
  local windowId = F.windowId()
  if not O.diagnostics[windowId] then
    O.diagnostics[windowId] = {}
  end
  return O.diagnostics[windowId]
end

return M
