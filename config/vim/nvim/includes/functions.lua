-- append: Add an item to a table
function append(container, item)
  table.insert(container, item)
end
-- color: Wrap a string in color highlight
function color(input, color)
  return '%#' .. color .. '#' .. input .. '%*'
end

-- Autocmd functions {{{
function autocmd(event, pattern, callback)
  local defaults = { 
    pattern = pattern,
    callback = callback
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  vim.api.nvim_create_autocmd(event, config)
end

-- ftdetect: Helper function to define a custom overide of filetype
function ftdetect(pattern, callback, options)
  autocmd({ 'BufRead', 'BufNewFile' }, pattern, callback, options)
end

-- ftplugin: Helper function to run a custom function on specific filetypes
function ftplugin(pattern, callback, options)
  autocmd('FileType', pattern, callback, options)
end
-- }}}

-- Mapping functions {{{
function map(mode, input, output, description, options)
  local defaults = { 
    silent = true, 
    noremap = true,
    nowait = true,
    desc = description, 
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  vim.keymap.set(mode, input, output, config)
end
-- Below functions should be used as:
-- nmap('{what to type}', '{what it should do}', '{description}')
function imap(input, output, description, options)
  map("i", input, output, description, options)
end
function nmap(input, output, description, options)
  map("n", input, output, description, options)
end
function vmap(input, output, description, options)
  map("x", input, output, description, options)
end
function cmap(input, output, description, options)
  map("c", input, output, description, options)
end
--- }}}

-- Color functions
local function getPalette()
  local palette = {}

  local env_COLORS_INDEX = os.getenv('COLORS_INDEX')
  local items = vim.split(env_COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = string.gsub(item, 'ALIAS_', '')
    local value = os.getenv('COLOR_' .. item .. '_HEXA')
    palette[key] = value
  end
  return palette
end
vim.g.palette = getPalette()

-- Highlight
function hl(groupName, colorName, options)
  local defaults = { 
    fg = vim.g.palette[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  -- Use color alias for background
  if config.bg ~= 'none' then
    config.bg = vim.g.palette[config.bg]
  end

  -- make XXX and YYY standout
  if colorName == 'XXX' then
    config = {
      fg = vim.g.palette.WHITE,
      bg = vim.g.palette.CYAN,
      bold = true,
    }
  end
  if colorName == 'YYY' then
    config = {
      fg = vim.g.palette.WHITE,
      bg = vim.g.palette.PURPLE,
    }
  end

  vim.api.nvim_set_hl(0, groupName, config)
end
-- }}}
