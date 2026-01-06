-- lua
F.ftplugin("lua", function()
  F.imap("$ù", "F.debug()<Left>", "Debug window", { buffer = F.bufferId() })
end)
