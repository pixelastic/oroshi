return {
  -- env: Get an environment variable
  env = function(name)
    return os.getenv(name)
  end,

  -- sendKey: Send a key without triggering custom keybindings
  sendKey = function(key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
  end,

  -- Visually mark Neovim as "thinking"
  setThinkingIndicator = function(isThinking)
    O.statusline.ai = { isThinking = isThinking }
    if isThinking then
      F.hl("Normal", "GRAY_3", { bg = "DARK_AMBER" })
    else
      F.hl("Normal", "GRAY_3")
    end
    vim.cmd("redrawstatus")
  end,
}
