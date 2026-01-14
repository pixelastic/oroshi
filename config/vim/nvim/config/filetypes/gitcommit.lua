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
    F.defer(function()
      F.setThinkingIndicator(true)
      F.info(" Generating commit message...")
    end, 100)

    F.run("git-commit-message-bin", {
      onSuccess = function(message)
        F.addLines(message.stdout, 1)
        F.setThinkingIndicator(false)
      end,
      onError = function(error)
        F.error("Failed to generate commit message: " .. error)
        F.setThinkingIndicator(false)
      end,
    })
  end
end)
