-- Increase cmdheight in Search and Command mode
local function setCmdHeight(newHeight)
  return function()
    vim.opt.cmdheight = newHeight

    vim.schedule(function()
      vim.cmd.redraw()
    end)
  end
end
autocmd('CmdlineEnter', '*', setCmdHeight(1))
autocmd('CmdlineLeave', '*', setCmdHeight(0))


-- Change cursor color in command and search
local function setCmdCursorColor()
  local type = vim.fn.getcmdtype()
  if type == ':' then
    hl('CursorModeCommandNormal', 'none', __.vars.cursor.hlDefault)
    hl('CursorModeCommandInsert', 'none', __.vars.cursor.hlDefault)
  end
  if type == '/' then
    hl('CursorModeCommandNormal', 'none', __.vars.cursor.hlSearch)
    hl('CursorModeCommandInsert', 'none', __.vars.cursor.hlSearch)
  end
end
autocmd('CmdlineEnter', '*', setCmdCursorColor)
