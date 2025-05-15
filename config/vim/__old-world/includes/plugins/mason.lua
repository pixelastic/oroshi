-- Mason, a package manager for vim
-- https://github.com/mason-org/mason.nvim
require("mason").setup()

-- Mason LSP Config, provides commands to install and enable LSP servers
-- Based on the community-driven list of LSP servers stored in the
-- neovim/nvim-lspconfig plugins
-- https://github.com/mason-org/mason-lspconfig.nvim
require("mason-lspconfig").setup {
    ensure_installed = { "bashls" },
}


local cmp = require('cmp')
