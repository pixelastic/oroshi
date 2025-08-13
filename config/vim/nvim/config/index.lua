-- O_require: Force load a specific module.
function O_require(path)
  local normalizedPath = path:gsub("/", ".")

  package.loaded[normalizedPath] = nil
  return require(normalizedPath)
end

-- Shared variables
O = {
  colors = {}, -- Mapping between color aliases and their hex values
  projects = {}, -- Mapping between projects and their colors and icons
  statusline = { -- Shared statusline info
    lsp = {},
    codecompanion = {}, -- CodeCompanion status
  },
  diagnostics = {}, -- Buffer-indexed diagnostics info
  folding = {}, -- Folding functions and helpers
  codecompanion = {}, -- Chat state
  nvimtree = {},
  dependencies = { -- Mason dependencies
    treesitters = {},
    lspServers = {},
    linters = {},
    formatters = {},
  },
}

-- Shared functions
F = vim.tbl_extend(
  "force",
  {},
  O_require("oroshi/functions/autocmd"),
  O_require("oroshi/functions/buffer"),
  O_require("oroshi/functions/collections"),
  O_require("oroshi/functions/debug"),
  O_require("oroshi/functions/hacks"),
  O_require("oroshi/functions/highlight"),
  O_require("oroshi/functions/lodash"),
  O_require("oroshi/functions/map"),
  O_require("oroshi/functions/misc"),
  O_require("oroshi/functions/modes"),
  O_require("oroshi/functions/tabs"),
  O_require("oroshi/functions/visual"),
  O_require("oroshi/functions/windows")
)

-- Colorscheme
O_require("oroshi/colorscheme")

-- Keybindings
O_require("oroshi/keybindings")

-- UI
O_require("oroshi/ui/commandline")
O_require("oroshi/ui/completion")
O_require("oroshi/ui/folding")
O_require("oroshi/ui/macro")
O_require("oroshi/ui/search")
O_require("oroshi/ui/statusline")
O_require("oroshi/ui/tabline")

-- Config
O_require("oroshi/display")
O_require("oroshi/disk")

-- Filetype specific
O_require("oroshi/filetypes/colors") -- Config files that should call colors-refresh
O_require("oroshi/filetypes/scrollback_pager") -- When nvim is used as a pager in kitty
O_require("oroshi/filetypes/config")
O_require("oroshi/filetypes/help")
O_require("oroshi/filetypes/markdown")
O_require("oroshi/filetypes/xkb")
O_require("oroshi/filetypes/zsh")

-- Plugins
-- Any config stored in plugins will NOT be reloaded when pressing <F2>, you
-- need a hard reload for that
require("oroshi/lazy")
