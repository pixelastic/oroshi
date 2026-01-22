-- sh
F.ftplugin("gitcommit", function()
  local bufferId = F.bufferId()

  -- Disable spellchecking
  F.defer(function()
    vim.opt_local.spell = false
  end)

  -- Ctrl-S: Save commit
  F.imap("<C-S>", "<CMD>silent! wq<CR>", "Save commit", { buffer = bufferId })
  F.nmap("<C-S>", "<CMD>silent! wq<CR>", "Save commit", { buffer = bufferId })
  F.vmap("<C-S>", "<CMD>silent! wq<CR>", "Save commit", { buffer = bufferId })

  -- Ctrl-D: Cancel commit
  F.imap("<C-D>", "<CMD>silent! cq<CR>", "Cancel commit", { buffer = bufferId })
  F.nmap("<C-D>", "<CMD>silent! cq<CR>", "Cancel commit", { buffer = bufferId })
  F.vmap("<C-D>", "<CMD>silent! cq<CR>", "Cancel commit", { buffer = bufferId })

  -- Set a generated message if none if set
  local firstLine = F.line(1)
  if F.isEmpty(firstLine) then
    F.setThinkingIndicator(true)
    F.replaceLines("Generating commit message, please wait...", 1)
    F.moveTo(1)

    F.run("git-commit-message-bin", {
      onSuccess = function(message)
        F.replaceLines(message.stdout, 1)
        F.setThinkingIndicator(false)
      end,
      onError = function(error)
        F.replaceLines("Failed to generate commit message: " .. error, 1)
        F.setThinkingIndicator(false)
      end,
    })
  end
end)
