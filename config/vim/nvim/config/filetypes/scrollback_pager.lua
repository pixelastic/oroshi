-- Scrollback pager
-- When bvim is used by Kitty as a pager (Alt-C)
F.ftplugin("scrollback_pager", function()
  -- Remove the line number
  vim.o.number = false

  -- Get the raw content of the buffer
  local rawBufferId = F.bufferId()
  local rawLinesList = F.bufferLines() -- current buffer
  local rawLinesText = F.trim(F.join(rawLinesList, "\n"))

  -- Pass it to a terminal (for automatic parsing), and set this terminal as the
  -- current buffer
  local coloredBufferId = F.createBuffer()
  local terminalChannel = vim.api.nvim_open_term(coloredBufferId, {})
  vim.api.nvim_chan_send(terminalChannel, rawLinesText)
  vim.api.nvim_win_set_buf(0, coloredBufferId)

  -- Scroll to the bottom
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
  -- Define the ft, so we can set a custom statusline
  vim.opt_local.ft = "pager"

  -- We wait until all initialization is done, then delete the original buffer
  -- If we don't wait we might mess some treesitter callback that expect the buffer
  -- to exist
  F.defer(function()
    F.closeBuffer(rawBufferId)
  end)
end)
