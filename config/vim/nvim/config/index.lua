-- frequire: Force load a specific module.
function frequire(path)
  local normalizedPath = path:gsub('/', '.')

  package.loaded[normalizedPath] = nil
  return require(normalizedPath)
end


-- Shared variables
O = {
  colors = {},
  projects = {},
  statusline = {},
  nvimtree = {}
}

-- Shared functions
F = vim.tbl_extend('force', {}, 
  frequire('oroshi/functions/autocmd'),
  frequire('oroshi/functions/buffer'),
  frequire('oroshi/functions/collections'),
  frequire('oroshi/functions/debug'),
  frequire('oroshi/functions/hacks'),
  frequire('oroshi/functions/highlight'),
  frequire('oroshi/functions/lodash'),
  frequire('oroshi/functions/map'),
  frequire('oroshi/functions/misc'),
  frequire('oroshi/functions/modes')
)

-- Colorscheme
frequire('oroshi/colorscheme')

-- Keybindings
frequire('oroshi/keybindings')

-- UI
frequire('oroshi/ui/commandline')
frequire('oroshi/ui/completion')
frequire('oroshi/ui/folding')
frequire('oroshi/ui/macro')
frequire('oroshi/ui/search')
frequire('oroshi/ui/statusline')
frequire('oroshi/ui/tabline')

-- Config
frequire('oroshi/display')
frequire('oroshi/disk')

-- Filetype specific
frequire('oroshi/filetypes')

-- Plugins
-- Any config stored in plugins will NOT be reloaded when pressing <F2>, you
-- need a hard reload for that
require('oroshi/lazy')
