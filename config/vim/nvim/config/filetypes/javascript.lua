local function setupJsKeybindings()
  local bufferId = F.bufferId()

  -- Regular keybindings
  F.imap("$ù", "console.log(", "Console log", { buffer = bufferId })
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = bufferId })

  -- describe('something', () => {
  -- });
  F.imap("dsc", function()
    vim.api.nvim_put({ "describe('', () => {", "\t\t", "\t});" }, "c", false, true)
    vim.cmd("normal! 2k^10l")
  end, "Insert describe() block", { buffer = bufferId })

  -- it('should do something', () => {
  -- });
  F.imap("iit", function()
    vim.api.nvim_put({ "it('', () => {", "\t\t", "\t});" }, "c", false, true)
    vim.cmd("normal! 2k^4l")
  end, "Insert it() test case", { buffer = bufferId })

  -- Expects
  F.imap("thp", "toHaveProperty(", "toHaveProperty assertion", { buffer = bufferId })
  F.imap("tbt", "toBe(true)", "toBe(true) assertion", { buffer = bufferId })
  F.imap("tbf", "toBe(false)", "toBe(false) assertion", { buffer = bufferId })
end

F.ftplugin("javascript", setupJsKeybindings)
F.ftplugin("typescript", setupJsKeybindings)
F.ftplugin("typescriptreact", setupJsKeybindings)
