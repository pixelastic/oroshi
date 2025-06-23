-- help
F.ftplugin(
  {'help', 'man'},
  function()
    -- Expand to full height
    local function takeAllHeight()
      vim.cmd('resize +999')
    end

    -- Expand again on each resize
    F.autocmd(
      {'VimResized', 'BufEnter' },
      takeAllHeight,
      { buffer = F.bufferId() }
    )
  end
)
