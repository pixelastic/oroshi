return {
  -- env: Get an environment variable
  env = function(name)
    return os.getenv(name)
  end,

  -- sendKey: Send a key without triggering custom keybindings
  sendKey = function(key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
  end,
}
