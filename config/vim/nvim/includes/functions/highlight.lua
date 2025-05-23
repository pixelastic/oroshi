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
  if not options then options = {} end
  -- Convert colors from short names
  if options.fg and options.fg ~= 'none' then options.fg = vim.g.colors[options.fg] end
  if options.bg and options.bg ~= 'none' then options.bg = vim.g.colors[options.bg] end

  local defaults = { 
    fg = vim.g.colors[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  -- make XXX and YYY standout
  if colorName == 'XXX' then
    config = { fg = vim.g.colors.WHITE, bold = true, }
  end
  if colorName == 'YYY' then
    config = { fg = vim.g.colors.WHITE, bg = vim.g.colors.PURPLE, }
  end

  vim.api.nvim_set_hl(0, groupName, config)
end

-- getHighlightGroups: Return table of all highlight groups under cursor
function getHighlightGroups()
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  if vim.api.nvim_get_mode().mode == 'i' then
    col = col - 1
  end

  local get_captures_at_pos = require('vim.treesitter').get_captures_at_pos
  local captures_at_cursor = vim.tbl_map(function(x)
    return x.capture
  end, get_captures_at_pos(buf, row, col))

  if vim.tbl_isempty(captures_at_cursor) then
    return {}
  end

  return captures_at_cursor
end

