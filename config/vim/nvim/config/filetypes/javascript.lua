-- zsh
F.ftplugin("javascript", function()
  F.imap("$ù", "console.log(", "Console log", { buffer = F.bufferId() })
end)
