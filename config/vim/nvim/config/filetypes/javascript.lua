-- zsh
F.ftplugin("javascript", function()
  F.imap("$ù", "console.log(", "Console log", { buffer = F.bufferId() })
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = F.bufferId() })
end)
