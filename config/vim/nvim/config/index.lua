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
  highlights = {}, -- All defined highlights (for restoring defaults)
  filetypeHighlights = {}, -- Filetype-specific highlight overrides
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
  -- LUA functions
  O_require("oroshi/functions/lodash"),
  O_require("oroshi/functions/collections"),
  -- Tabs / Splits / Buffers / Lines / Options / Nodes
  O_require("oroshi/functions/tabs"),
  O_require("oroshi/functions/splits"),
  O_require("oroshi/functions/buffers"),
  O_require("oroshi/functions/lines"),
  O_require("oroshi/functions/options"),
  O_require("oroshi/functions/nodes"),
  -- Modes
  O_require("oroshi/functions/modes"),
  O_require("oroshi/functions/visual"),
  -- Other aspects of vim
  O_require("oroshi/functions/autocmd"),
  O_require("oroshi/functions/map"),
  O_require("oroshi/functions/highlight"),
  -- HTTP & AI
  O_require("oroshi/functions/http"),
  O_require("oroshi/functions/ai"),
  O_require("oroshi/functions/jsdoc"),
  -- Filesystem
  O_require("oroshi/functions/file"),
  O_require("oroshi/functions/git"),
  O_require("oroshi/functions/shell"),
  -- Debug
  O_require("oroshi/functions/debug"),
  O_require("oroshi/functions/hacks"),
  O_require("oroshi/functions/misc")
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

-- Filetypes
local vimConfigFolder = F.dirname(debug.getinfo(1, "S").short_src)
local filetypePaths = F.glob("./filetypes/*.lua", {
  cwd = vimConfigFolder,
})
F.each(filetypePaths, function(filetypePath)
  local filetype = F.filename(filetypePath)
  local module = O_require("oroshi.filetypes." .. filetype)

  -- Always fired
  if module.onInit then
    module.onInit()
  end

  -- Fired only when the specific filetype is loaded
  if module.onFiletype then
    F.ftplugin(filetype, module.onFiletype)

    -- if .filetypeAliases is defined, apply the same onFiletype to the aliases
    F.each(module.filetypeAliases or {}, function(aliasName)
      F.ftplugin(aliasName, module.onFiletype)
    end)
  end
end)

-- Plugins
-- Any config stored in plugins will NOT be reloaded when pressing <F2>, you
-- need a hard reload for that
require("oroshi/lazy")
