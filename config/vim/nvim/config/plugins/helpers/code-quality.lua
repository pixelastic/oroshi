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
function M.synchronizeDependencies(expectedDependencies)
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


return M
