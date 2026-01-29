-- lua
F.ftplugin("lua", function()
  F.imap("$ù", "F.warn()<Left>", "Debug window", { buffer = F.bufferId() })
end)
