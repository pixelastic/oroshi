-- Scrollback pager
-- When bvim is used by Kitty as a pager (Alt-C)
F.ftplugin("scrollback_pager", function()
  local buf = vim.api.nvim_get_current_buf()
  local b = vim.api.nvim_create_buf(false, true)
  local chan = vim.api.nvim_open_term(b, {})
  vim.api.nvim_chan_send(chan, table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
  vim.api.nvim_win_set_buf(0, b)
  -- -- Expand to full height
  -- local function takeAllHeight()
  --   vim.cmd("resize +999")
  -- end
  --
  -- -- Expand again on each resize
  -- F.autocmd({ "VimResized", "BufEnter" }, takeAllHeight, { buffer = F.bufferId() })
end)
