local autocmd = F.autocmd
local M = {}

-- Install, load and configure all LSP servers
-- Full list available on:
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
M.loadServers = function()
  require("mason").setup()

  -- Specific LSP servers need to be configured before being installed
  M.configureLuaServer()

  require("mason-lspconfig").setup({
    ensure_installed = {
      "lua_ls"
    }
  })
end

-- Configure the Lua LSP server
M.configureLuaServer = function()
  require('lspconfig').lua_ls.setup({
    on_init = function(client)
      -- Make it aware of vim-specific globals
      local config = {
        runtime = { version = 'LuaJIT' },
        workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
      }
      client.config.settings.Lua = F.merge(client.config.settings.Lua, config)
    end,
  })
end


-- Configure nvim diagnostic engine
M.configureDiagnostics = function()
  vim.diagnostic.config({
    update_in_insert = false, -- Do not pollute with warning in insert mode
    signs = {
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticLineNrError',
        [vim.diagnostic.severity.WARN] = 'DiagnosticLineNrWarn',
        [vim.diagnostic.severity.INFO] = 'DiagnosticLineNrInfo',
        [vim.diagnostic.severity.HINT] = 'DiagnosticLineNrHint',
      },
    },
    -- Uncomment following lines to enable other display types
    -- virtual_text = { prefix = "█", current_line = true }, -- Virtual text
    -- virtual_lines = { current_line = true }, -- Virtual lines
  })
end

-- Configure the diag line displayed at the bottom
M.configureDiagLine = function()
  O.diagnostics = {}

  -- Update it whenever the cursor moves
  autocmd('CursorMoved', function()
    local data = M.getDiagData()
    local currentLineNumber = F.lineNumber()

    -- Same line: Do nothing
    if data.lineNumber == currentLineNumber then return end
    data.lineNumber = currentLineNumber -- Update current line

    -- No error: We hide
    local error = M.getErrorDetails(currentLineNumber)
    if not error then
      M.hideDiagLine(data)
      return
    end

    -- Update content of the diag line
    M.updateDiagLine(data, error)
  end)
end

-- Returns the diag data (lineNumber, windowId, bufferId)
M.getDiagData = function()
  local windowId = F.windowId()
  if not O.diagnostics[windowId] then
    O.diagnostics[windowId] = {}
  end
  return O.diagnostics[windowId]
end

-- Create a (hidden) diag line, as a window at the bottom of the screen
M.createDiagLine = function(data)
  local width = F.windowWidth()
  local height = F.windowHeight()

  -- Create a buffer
  data.bufferId = vim.api.nvim_create_buf(false, true)

  -- Put that buffer into a window
  data.windowId = vim.api.nvim_open_win(data.bufferId, false, {
    relative = 'win',
    anchor = 'SW',
    row = height,
    col = 0,
    width = width,
    height = 1,
    style = 'minimal',
    focusable = false,
    hide = true,
  })
end

-- Hide the diag line
M.hideDiagLine = function(data)
  if not data.windowId then
    return
  end

  vim.api.nvim_win_set_config(data.windowId, { hide = true })
end

-- Update the content of the diag line
M.updateDiagLine = function(data, error)
  if not data.windowId then
    M.createDiagLine(data)
  end

  -- Update content
  vim.api.nvim_buf_set_lines(
    data.bufferId,    -- bufferId
    0, -1,            -- Range, from beginning to end 
    false,            -- Do not error if adds more lines than previously
    { error.content } -- Actual content
  )

  -- Change highlight groups
  local severityToHighlight = {
    [vim.diagnostic.severity.ERROR] = 'DiagnosticDiagLineError',
    [vim.diagnostic.severity.WARN] = 'DiagnosticDiagLineWarn',
    [vim.diagnostic.severity.INFO] = 'DiagnosticDiagLineInfo',
    [vim.diagnostic.severity.HINT] = 'DiagnosticDiagLineHint',
  }
  vim.api.nvim_set_option_value(
    'winhighlight',
    'Normal:' .. severityToHighlight[error.severity],
    { win = data.windowId }
  )

  -- Show window
  vim.api.nvim_win_set_config(data.windowId, {
    width = F.windowWidth(),
    hide = false
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
    content = diag[1].code .. ' : ' .. diag[1].message
  }
end

-- Configure the statusline to listen to LSP loading
M.configureStatusline = function()
  -- Update the statusline when LSP is loading
  F.autocmd('LspProgress', function()
    local bufferId = F.bufferId()
    O.statusline.lsp['buf'..bufferId] = 'loading'

    vim.cmd("redrawstatus")
  end, { pattern = 'begin'})

  -- Update statusbar when LSP is updated
  F.autocmd('DiagnosticChanged', function()
    -- Find errors in that buffer
    local bufferId = F.bufferId()
    local errors = vim.diagnostic.get(bufferId)

    -- Update the statusbar status
    local severity = M.getHighestSeverity(errors)
    O.statusline.lsp['buf'..bufferId] = severity

    -- Hide the diag line if everything is clean
    if severity == 'success' then
      M.hideDiagLine(M.getDiagData())
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
M.severityStringToInt = function(severityString)
  local severities = {
    error = vim.diagnostic.severity.ERROR,

    warning = vim.diagnostic.severity.WARN,
    warn = vim.diagnostic.severity.WARN,

    info = vim.diagnostic.severity.INFO,

    style = vim.diagnostic.severity.HINT,
    hint = vim.diagnostic.severity.HINT,

    success = 5
  }
  return severities[severityString];
end

M.configureZshlint = function()
  local lint = require("lint")

  -- Parser to convert CLI output to diagnostics
  local zshLintParser = function(output)
    if output == "" then return {} end
    local decoded = vim.json.decode(output)
    local diagnostics = {}
    for _, item in ipairs(decoded or {}) do
      local code = item.code
      local message = item.message

      -- [SC2154]
      -- This is a rule that flags unused variables. It cannot understand the
      -- zparseopts syntax to define variables from args passed to the
      -- commandline, so it flags some false positives. We will ignore it
      -- on purpose when the variable starts with flag*, which is the pattern I use
      if code == 2154 and F.startsWith(message, "flag") then
        goto continue
      end

      F.append(diagnostics, {
        source = "zshlint",
        code = "SC" .. item.code,
        message = item.message,
        severity = M.severityStringToInt(item.level),

        lnum = item.line - 1,
        end_lnum = item.endLine - 1,
        col = item.column - 1,
        end_col = item.endColumn - 1,
        user_data = {
          lsp = {
            code = item.code,
          },
        },
      })

      ::continue::
    end
    return diagnostics
  end

  -- Add a new named linter
  lint.linters.zshlint = {
    cmd = "zshlint",
    stdin = false,
    ignore_exitcode = true,
    parser = zshLintParser
  }
end


return M
