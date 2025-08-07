local helperLsp = O_require("oroshi/plugins/helpers/lsp")
local helperDiagline = O_require("oroshi/plugins/helpers/diagline")
local helperStatusline = O_require("oroshi/plugins/helpers/statusline")
local helperZsh = O_require("oroshi/plugins/helpers/zsh")
local helperLua = O_require("oroshi/plugins/helpers/lua")
O.dependencies = {
	-- Treesitter:
	-- https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#supported-languages
	treesitters = {
		"bash",
		"comment",
		"css",
		"csv",
		"diff",
		"dockerfile",
		"editorconfig",
		"gitignore",
		"git_config",
		"html",
		"ini",
		"javascript",
		"jsdoc",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"nginx",
		"pug",
		"python",
		"regex",
		"robots",
		"ruby",
		"ssh_config",
		"xml",
		"yaml",
	},
	lspServers = {
		"lua_ls",
	},
	linters = {},
	formatters = {
		"prettier",
		"shfmt",
		"stylua",
	},
}

return {
	-- Dependencies: Mason
	-- https://github.com/mason-org/mason.nvim
	-- Install all required dependencies, like LSP servers, linters or formatters
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()

			-- Install all missing dependencies
			local masonRegistry = require("mason-registry")
			local masonDependencies = F.concat(O.dependencies.formatters, O.dependencies.linters)
			F.each(masonDependencies, function(dependency)
				if not masonRegistry.is_installed(dependency) then
					vim.cmd("MasonInstall " .. dependency)
				end
			end)

			-- Configure various parts of the UI that depends on those dependencies
			helperDiagline.init()
			helperStatusline.init()
		end,
	},

	-- Treesitter
	-- https://github.com/nvim-treesitter/nvim-treesitter
	-- Treesitter is fast and static, and understands the structure of code.
	-- It can be used for highlight, indentation, folding, etc
	{
		"nvim-treesitter/nvim-treesitter",
		version = "0.25.4",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter.configs")

			treesitter.setup({
				ensure_installed = O.dependencies.treesitters,

				highlight = {
					-- Advanced syntax highlight
					enable = true,
					additional_vim_regex_highlighting = false,
				},

				-- Select node with vv (then expand with CTRL-J / CTRL-K)
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "vv", -- Select node
						node_incremental = "<C-K>", -- Select parent node
						node_decremental = "<C-J>", -- Deselect parent node
						scope_incremental = false,
					},
				},

				-- Indent selection with =
				indent = {
					enable = true,
				},
			})
		end,
	},

	-- LSP
	-- Installs LSP servers and configure them.
	-- https://github.com/mason-org/mason-lspconfig.nvim
	-- https://github.com/neovim/nvim-lspconfig
	--
	-- LSP servers are complex dynamic systems that understand code as we type.
	-- They can be used for auto-completion, type definition, linting,
	-- refactoring, etc
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			helperLsp.init(O.dependencies.lspServers)
		end,
	},

	-- Linters: nvim-lint
	-- https://github.com/mfussenegger/nvim-lint
	-- Spawns linter asynchronously and display results
	-- This should be used only when LSP Diagnostics are not enough
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters = {}
			lint.linters_by_ft = {}

			-- Configure language-specific formatters that require more work
			helperZsh.configureLinter()

			F.autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, function()
				lint.try_lint()
			end)
		end,
	},

	-- Formatters: conform
	-- https://github.com/stevearc/conform.nvim
	-- Format code automatically
	{
		"stevearc/conform.nvim",
		dependencies = {
			"mason-org/mason.nvim",
		},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					bash = { "shfmt" },
					json = { "prettier" },
					lua = { "stylua" },
					sh = { "shfmt" },
				},
				format_on_save = {
					timeout_ms = 500,
				},
			})

			-- Configure language-specific formatters that require more work
			helperZsh.configureFormatter()
			helperLua.configureFormatter()
		end,
	},

	-- mini.trailspace
	-- https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-trailspace.md
	-- Remove trailing spaces on save
	{
		"echasnovski/mini.trailspace",
		version = "*",
		config = function()
			local trailspace = require("mini.trailspace")
			F.autocmd("BufWritePre", function()
				trailspace.trim() -- Remove trailing spaces
				trailspace.trim_last_lines() -- Remove trailing lines
			end)
		end,
	},
}
