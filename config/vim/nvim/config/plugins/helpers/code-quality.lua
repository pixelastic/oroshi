local M = {}

local filetypeHelpers = {
  O_require("oroshi/plugins/helpers/filetypes/bash"),
  O_require("oroshi/plugins/helpers/filetypes/json"),
  O_require("oroshi/plugins/helpers/filetypes/lua"),
  O_require("oroshi/plugins/helpers/filetypes/sh"),
  O_require("oroshi/plugins/helpers/filetypes/toml"),
  O_require("oroshi/plugins/helpers/filetypes/zsh"),
}

-- If it exists, run the given method for each configured filetype helper.
function M.runForAllFiletypes(methodName)
  F.each(filetypeHelpers, function(helper)
    if helper[methodName] then
      helper[methodName]()
    end
  end)
end

function M.installedTreesitter()
  local parsers = require("nvim-treesitter.info").installed_parsers()
  table.sort(parsers)
  return parsers
end

function M.debug()
  local output = {}
  -- TreeSitter
  F.append(output, "# TreeSitter")
  F.append(output, "")
  F.each(M.installedTreesitter(), function(parser)
    F.append(output, "  - " .. parser)
  end)

  local bufferOptions = {
    ft = "markdown",
  }
  F.createFloatingSplit(F.join(output, "\n"), { options = bufferOptions })
end

vim.api.nvim_create_user_command("CodeQualityDebug", M.debug, {})

-- -- Fonction pour afficher l'output dans une fenêtre flottante
-- local function show_code_quality_debug()
--   local info = getTreeSitterInfo() -- Assurez-vous que cette fonction existe et retourne une string
-- end

-- local function getMasonInfo()
--   local registry = require("mason-registry")
--   local installed = {}
--
--   for _, pkg in ipairs(registry.get_installed_packages()) do
--     table.insert(installed, {
--       name = pkg.name,
--       type = pkg.spec.categories[1] or "unknown",
--     })
--   end
--
--   table.sort(installed, function(a, b)
--     return a.name < b.name
--   end)
--   return installed
-- end
--
-- local function getLspInfo()
--   local clients = {}
--   local bufnr = vim.api.nvim_get_current_buf()
--   local active_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
--
--   for _, client in ipairs(active_clients) do
--     table.insert(clients, {
--       name = client.name,
--       filetypes = client.config.filetypes or {},
--       root_dir = client.config.root_dir or "unknown",
--     })
--   end
--
--   return clients
-- end
--
-- local function getConformInfo()
--   local ok, conform = pcall(require, "conform")
--   if not ok then
--     return {}
--   end
--
--   local formatters_by_ft = conform.list_all_formatters()
--   local result = {}
--
--   for ft, formatters in pairs(formatters_by_ft) do
--     result[ft] = vim.tbl_map(function(f)
--       return f.name
--     end, formatters)
--   end
--
--   return result
-- end
--
-- local function getLintInfo()
--   local ok, lint = pcall(require, "lint")
--   if not ok then
--     return {}
--   end
--
--   return lint.linters_by_ft or {}
-- end

local function showDebugInfo()
  local lines = {}

  -- Header
  table.insert(lines, "=== CODE QUALITY DEBUG INFO ===")
  table.insert(lines, "")

  -- Current buffer info
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  table.insert(lines, "Current Buffer:")
  table.insert(lines, "  Filetype: " .. (filetype ~= "" and filetype or "none"))
  table.insert(lines, "")

  -- Treesitter parsers
  table.insert(lines, "Treesitter Parsers Installed:")
  local parsers = getTreesitterInfo()
  for _, parser in ipairs(parsers) do
    table.insert(lines, "  ✓ " .. parser)
  end
  table.insert(lines, "")

  -- Mason packages
  table.insert(lines, "Mason Packages:")
  local mason_pkgs = getMasonInfo()
  local categorized = {}
  for _, pkg in ipairs(mason_pkgs) do
    if not categorized[pkg.type] then
      categorized[pkg.type] = {}
    end
    table.insert(categorized[pkg.type], pkg.name)
  end

  for category, pkgs in pairs(categorized) do
    table.insert(lines, "  " .. category .. ":")
    for _, name in ipairs(pkgs) do
      table.insert(lines, "    • " .. name)
    end
  end
  table.insert(lines, "")

  -- Active LSP clients
  table.insert(lines, "Active LSP Clients (current buffer):")
  local lsp_clients = getLspInfo()
  if #lsp_clients > 0 then
    for _, client in ipairs(lsp_clients) do
      table.insert(lines, "  • " .. client.name)
      if #client.filetypes > 0 then
        table.insert(lines, "    Filetypes: " .. table.concat(client.filetypes, ", "))
      end
    end
  else
    table.insert(lines, "  (none)")
  end
  table.insert(lines, "")

  -- Formatters by filetype
  table.insert(lines, "Formatters by Filetype:")
  local formatters = getConformInfo()
  if vim.tbl_count(formatters) > 0 then
    for ft, fmt_list in pairs(formatters) do
      table.insert(lines, "  " .. ft .. ": " .. table.concat(fmt_list, ", "))
    end
  else
    table.insert(lines, "  (none configured)")
  end
  table.insert(lines, "")

  -- Linters by filetype
  table.insert(lines, "Linters by Filetype:")
  local linters = getLintInfo()
  if vim.tbl_count(linters) > 0 then
    for ft, lint_list in pairs(linters) do
      table.insert(lines, "  " .. ft .. ": " .. table.concat(lint_list, ", "))
    end
  else
    table.insert(lines, "  (none configured)")
  end

  -- Create buffer and show
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

  -- Open in split
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_height(0, math.min(#lines + 2, 30))
end

local function showCurrentFiletypeInfo()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  if filetype == "" then
    vim.notify("No filetype set for current buffer", vim.log.levels.WARN)
    return
  end

  local lines = {}
  table.insert(lines, "=== " .. string.upper(filetype) .. " Configuration ===")
  table.insert(lines, "")

  -- Check Treesitter
  local parsers = getTreesitterInfo()
  local has_parser = vim.tbl_contains(parsers, filetype)
  table.insert(lines, "Treesitter: " .. (has_parser and "✓ Installed" or "✗ Not installed"))

  -- Check LSP
  local lsp_clients = getLspInfo()
  table.insert(lines, "")
  table.insert(lines, "LSP Servers:")
  if #lsp_clients > 0 then
    for _, client in ipairs(lsp_clients) do
      table.insert(lines, "  • " .. client.name)
    end
  else
    table.insert(lines, "  (none active)")
  end

  -- Check Formatters
  local formatters = getConformInfo()
  table.insert(lines, "")
  table.insert(lines, "Formatters:")
  if formatters[filetype] then
    for _, fmt in ipairs(formatters[filetype]) do
      table.insert(lines, "  • " .. fmt)
    end
  else
    table.insert(lines, "  (none configured)")
  end

  -- Check Linters
  local linters = getLintInfo()
  table.insert(lines, "")
  table.insert(lines, "Linters:")
  if linters[filetype] then
    for _, lnt in ipairs(linters[filetype]) do
      table.insert(lines, "  • " .. lnt)
    end
  else
    table.insert(lines, "  (none configured)")
  end

  -- Show in floating window
  local width = 50
  local height = #lines
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Code Quality Info ",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Close on any key
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
end

return M

