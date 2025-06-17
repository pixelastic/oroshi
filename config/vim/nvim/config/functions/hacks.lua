return {
  -- defer: Wait a bit and execute the callback
  defer = function(callback, timeout)
    vim.defer_fn(callback, timeout or 0)
  end,

  -- ensureVisualSelection
  ensureVisualSelection = function()
    -- '< and '> marks are only updated when leaving visual mode
    -- So if we need to use them in a lua method, we first need to leave and
    -- quickly come back in visual mode to be able to use '< and '> in the
    -- mapping
    F.normalMode()      -- <Esc> to leave visual mode
    vim.cmd('normal gv') -- Reselecting previous selection
  end,

  -- hideCompletionWildmenu: Hide the wildmenu
  -- In insert mode, we use the Wildmenu to "display" (black on black) the
  -- completion suggestions. This allows for Ghost Text to work
  hideCompletionWildmenu = function()
    F.each(O.colors.completion.hidden, function(value, key)
      F.hl(key, 'none', value)
    end)
  end,
  -- showCompletionWildmenu: Show the wildmenu
  -- In command mode, we use the Wildmenu for real completion, so we need to
  -- show it with a readable hightlight
  showCompletionWildmenu = function()
    F.each(O.colors.completion.visible, function(value, key)
      F.hl(key, 'none', value)
    end)
  end,

  withReadableMsgArea = function(callback)
    callback()
  end

  -- __.commandline = {
  --   setHighlightHidden = function()
  --     hl('MsgArea', 'none', __.vars.commandline.hlHidden)
  --   end,
  --   setHighlightVisible = function()
  --     hl('MsgArea', 'none', __.vars.commandline.hlVisible)
  --   end,
  --
  --   -- withReadableMsgArea: Call function in a readable zone
  --   withReadableMsgArea = function(callback)
  --     __.commandline.setHighlightVisible()
  --
  --     vim.schedule(function()
  --       callback()
  --       __.commandline.setHighlightHidden()
  --     end)
  --   end
  -- }
}
