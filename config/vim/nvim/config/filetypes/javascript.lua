local function setupJsKeybindings()
  local bufferId = F.bufferId()

  -- Regular keybindings
  F.imap("$ù", "console.log(", "Console log", { buffer = bufferId })
  F.imap("##", "${}<Left>", "Create interpolated variable", { buffer = bufferId })

  -- JSDoc generation
  F.nmap("<C-:>", F.generateJsDoc, "Generate JSDoc for function under cursor", { buffer = bufferId })

  -- describe('something', () => {
  -- });
  F.imap("dsc", function()
    vim.api.nvim_put({ "describe('', () => {", "\t\t", "\t});" }, "c", false, true)
    vim.cmd("normal! 2k^10l")
  end, "describe()", { buffer = bufferId })

  -- it('should do something', () => {
  -- });
  F.imap("iit", function()
    vim.api.nvim_put({ "it('', () => {", "\t\t", "\t});" }, "c", false, true)
    vim.cmd("normal! 2k^4l")
  end, "it()", { buffer = bufferId })

  -- it.each([
  --   ['input', 'expected']
  -- ])('%s => %s', async () => {
  -- });
  F.imap("iite", function()
    vim.api.nvim_put({
      "it.each([",
      "\t\t['input', 'expected'],",
      "\t\t['input', 'expected']",
      "\t])('%s => %s', async (input, expected) => {",
      "\t\tconst actual = current(input);",
      "\t\texpect(actual).toEqual(expected);",
      "\t});",
    }, "c", false, true)
    vim.cmd("normal! 5k^2l")
    F.normalMode()
  end, "it.each()", { buffer = bufferId })

  -- vi.spyOn()
  F.imap("vspo", function()
    vim.api.nvim_put({ "vi.spyOn()" }, "c", false, true)
    vim.cmd("normal! 1h")
  end, "vi.spyOn()", { buffer = bufferId })

  -- Expects
  F.imap("thp", "toHaveProperty(", "toHaveProperty assertion", { buffer = bufferId })
  F.imap("tbt", "toBe(true)", "toBe(true) assertion", { buffer = bufferId })
  F.imap("tbf", "toBe(false)", "toBe(false) assertion", { buffer = bufferId })
  F.imap("mrv", "mockReturnValue()", "mockReturnValue()", { buffer = bufferId })
end

F.ftplugin("javascript", setupJsKeybindings)
F.ftplugin("javascriptreact", setupJsKeybindings)
F.ftplugin("typescript", setupJsKeybindings)
F.ftplugin("typescriptreact", setupJsKeybindings)
