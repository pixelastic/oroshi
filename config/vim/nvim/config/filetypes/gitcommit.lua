-- sh
F.ftplugin("gitcommit", function()
  -- Disable spellchecking
  F.defer(function()
    vim.opt_local.spell = false
  end)
end)
