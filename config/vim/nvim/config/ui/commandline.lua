local autocmd = F.autocmd
local hl = F.hl

-- Increase cmdheight in Search and Command mode {{{
local function setCmdHeight(newHeight)
  return function()
    vim.opt.cmdheight = newHeight

    vim.schedule(function()
      vim.cmd.redraw()
    end)
  end
end
autocmd('CmdlineEnter', setCmdHeight(1))
autocmd('CmdlineLeave', setCmdHeight(0))
-- }}}

-- Change cursor color in command and search {{{
local function setCmdCursorColor()
  if F.isCommandMode() then
    hl('CursorModeCommandNormal', 'none', O.colors.cursor.command)
    hl('CursorModeCommandInsert', 'none', O.colors.cursor.command)
  end
  if F.isSearchMode() then
    hl('CursorModeCommandNormal', 'none', O.colors.cursor.search)
    hl('CursorModeCommandInsert', 'none', O.colors.cursor.search)
  end
end
autocmd('CmdlineEnter', setCmdCursorColor)
-- }}}

-- Hide MsgArea {{{
-- __.commandline.setHighlightHidden()
-- }}}

