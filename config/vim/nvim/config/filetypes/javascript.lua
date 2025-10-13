local function setupJsKeybindings()
  F.imap("$ù", "console.log(", "Console log", { buffer = F.bufferId() })
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = F.bufferId() })
end

F.ftplugin("javascript", setupJsKeybindings)
F.ftplugin("typescript", setupJsKeybindings)
F.ftplugin("typescriptreact", setupJsKeybindings)
