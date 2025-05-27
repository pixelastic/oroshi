-- color: Wrap a string in color highlight
function color(input, color)
  return '%#' .. color .. '#' .. input .. '%*'
end

-- hl: Define colors for a specific highlight group
-- Usage:
-- hl('Comment', 'RED')                                 -- Foreground color only
-- hl('Comment', 'RED', { bg = 'GREEN' })               -- Also background
-- hl('Comment', 'RED', { bold = true })                -- Also bold
-- hl('Comment', 'RED', { blend = 100 })                -- Transparent background, doesn't always work
-- hl('Comment', 'none', { bg = 'GREEN' })              -- Keep foreground as parent
-- hl('Comment', 'none', { fg = 'RED', bg = 'GREEN' })  -- Pass everything in last arg
function hl(groupName, colorName, options)
  -- Default options
  if not options then options = {} end
  options = __._.clone(options) -- Prevent subtables to be modified when passed by reference

  -- Convert colors from short names
  if options.fg and options.fg ~= 'none' then options.fg = vim.g.colors[options.fg] end
  if options.bg and options.bg ~= 'none' then options.bg = vim.g.colors[options.bg] end

  local defaults = { 
    fg = vim.g.colors[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = __._.merge(defaults, options)

  -- make XXX and YYY standout
  if colorName == 'XXX' then
    config = { fg = vim.g.colors.WHITE, bg = vim.g.colors.CYAN, bold = true, }
  end
  if colorName == 'YYY' then
    config = { fg = vim.g.colors.WHITE, bg = vim.g.colors.PURPLE, }
  end

  vim.api.nvim_set_hl(0, groupName, config)
end

-- getHighlightGroups: Return table of all highlight groups under cursor
function getHighlightGroups()
  local bufferId = __.getBufferId()
  local cursor = __.getCursor()

  -- Get groups defined by Treesitter
  local function getTreesitterCaptures(bufferId, cursor)
    local treesitter = require('vim.treesitter')

    local row = cursor.row - 1
    local col = cursor.col
    if __.isInsertMode() then
      col = col - 1
    end

    local allCaptures = treesitter.get_captures_at_pos(bufferId, row, col)
    return __._.map(allCaptures, 'capture')
  end

  -- Get groups defined by syntax
  local function getSyntaxCaptures(bufferId, cursor)
    local row = cursor.row
    local col = cursor.col
    if not __.isInsertMode() then
      col = col + 1
    end

    local ret = {}
    for _, synId in ipairs(vim.fn.synstack(row, col)) do
      synId = vim.fn.synIDtrans(synId)
      local synName = vim.fn.synIDattr(synId, 'name')
      __.append(ret, synName)
    end

    return ret
  end


  local treesitterCaptures = getTreesitterCaptures(bufferId, cursor)
  local syntaxCaptures = getSyntaxCaptures(bufferId, cursor)
  return __._.concat(treesitterCaptures, syntaxCaptures)
end


