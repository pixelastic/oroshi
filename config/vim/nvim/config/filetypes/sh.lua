-- sh
F.ftplugin("sh", function()
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = F.bufferId() })
end)
