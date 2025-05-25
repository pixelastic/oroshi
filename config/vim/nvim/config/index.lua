-- frequire: Force load a specific module.
function frequire(path)
  local normalizedPath = path:gsub('/', '.')

  package.loaded[normalizedPath] = nil
  require(normalizedPath)
end

-- Functions
frequire('oroshi/functions')

-- Colorscheme
frequire('oroshi/colorscheme')

-- Keybindings
frequire('oroshi/keybindings')

-- UI
frequire('oroshi/ui')

-- Config
frequire('oroshi/display')
frequire('oroshi/disk')

-- Filetype specific
frequire('oroshi/filetypes')

-- Plugins
-- Any config stored in plugins will NOT be reloaded when pressing <F2>, you
-- need a hard reload for that
require('oroshi/lazy')
