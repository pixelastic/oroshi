local M = {}

-- Track which LSP servers have been manually configured
M.manuallyConfiguredLspServers = {}

-- Configure an LSP server and track that it was manually configured
function M.configureLspServer(serverName, options)
  local lspconfig = require("lspconfig")

  -- Mark this server as manually configured
  F.append(M.manuallyConfiguredLspServers, serverName)

  -- Do the actual setup
  lspconfig[serverName].setup(options)
end

-- Synchronize Mason dependencies: install missing ones, uninstall unused ones
function M.synchronizeMasonDependencies(expectedDependencies)
  local masonRegistry = require("mason-registry")

  local installedPackages = F.map(masonRegistry.get_installed_packages(), "name")
  local dependenciesToUninstall = F.difference(installedPackages, expectedDependencies)

  -- Install missing dependencies
  F.each(expectedDependencies, function(dependency)
    if not masonRegistry.is_installed(dependency) then
      vim.cmd("MasonInstall " .. dependency)
    end
  end)

  -- Uninstall old dependencies
  F.each(dependenciesToUninstall, function(dependency)
    vim.cmd("MasonUninstall " .. dependency)
  end)
end

-- Synchronize Treesitter parsers: install expected ones, uninstall unused ones
function M.synchronizeTreesitterParsers(expectedParsers)
  local treesitterInstall = require("nvim-treesitter.install")

  -- Get installed parsers, excluding core ones native to Neovim
  local installedParsers = require("nvim-treesitter.info").installed_parsers()
  local coreParsers = { "c", "lua", "vim", "vimdoc", "query" }
  local userInstalledParsers = F.sort(F.difference(installedParsers, coreParsers))

  local parsersToUninstall = F.difference(userInstalledParsers, expectedParsers)

  -- Uninstall unused parsers
  F.each(parsersToUninstall, function(parserName)
    treesitterInstall.uninstall(parserName)
  end)

  -- Note: Installation will be handled by ensure_installed in treesitter config
  -- This approach is more reliable than manual installation
end

-- Configure all LSP servers based on the filetypes config
function M.configureLspServers(filetypesConfig)
  local lspconfig = require("lspconfig")
  local mason_lspconfig = require("mason-lspconfig")

  -- Setup mason-lspconfig, but disable automatic installation
  mason_lspconfig.setup({
    ensure_installed = {},
    automatic_enable = false,
  })

  -- Run custom configureLsp functions
  local configureLspFunctions = F.compact(F.map(filetypesConfig, "configureLsp"))
  F.each(configureLspFunctions, function(configureLsp)
    configureLsp()
  end)

  -- Setup remaining LSP servers with default config
  local allLspServers = F.uniq(F.flatten(F.compact(F.map(filetypesConfig, "lsp"))))
  local lspServersToSetup = F.difference(allLspServers, M.manuallyConfiguredLspServers)
  F.each(lspServersToSetup, function(lspServer)
    lspconfig[lspServer].setup({})
  end)
end

-- Configure all linters based on the filetypes config
function M.configureLinters(filetypesConfig)
  local lint = require("lint")
  lint.linters = {}
  lint.linters_by_ft = {}

  -- Configure linters based on filetypeConfig
  F.each(filetypesConfig, function(config, filetype)
    if not config.linters or F.isEmpty(config.linters) then
      return
    end
    lint.linters_by_ft[filetype] = config.linters
  end)

  -- Run all configureLinter functions
  local configureLinterFunctions = F.compact(F.map(filetypesConfig, "configureLinter"))
  F.each(configureLinterFunctions, function(configureLinter)
    configureLinter(lint)
  end)
end

-- Configure all formatters based on the filetypes config
function M.configureFormatters(filetypesConfig)
  local conform = require("conform")

  -- Build formatters_by_ft from filetypeConfig
  local formatters_by_ft = {}
  F.each(filetypesConfig, function(config, filetype)
    if not config.formatters or F.isEmpty(config.formatters) then
      return
    end
    formatters_by_ft[filetype] = config.formatters
  end)

  conform.setup({
    formatters_by_ft = formatters_by_ft,
    log_level = vim.log.levels.DEBUG,

    -- We allow dynamically disabling the format_on_save per filetype from the config
    -- Note: This is useful if we want to add other pre-processing transforms
    -- manually before formatting (like for js)
    format_on_save = function(bufnr)
      local filetype = F.bufferOption("filetype")

      if filetypesConfig[filetype].disableConformFormatOnSave then
        return nil
      end

      return { timeout_ms = 3000 }
    end,
  })

  -- Run all configureFormatter functions
  local configureFormatterFunctions = F.compact(F.map(filetypesConfig, "configureFormatter"))
  F.each(configureFormatterFunctions, function(configureFormatter)
    configureFormatter(conform)
  end)
end

return M
