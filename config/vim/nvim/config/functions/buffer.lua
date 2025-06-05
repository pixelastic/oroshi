return {
  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand('%') == ''
  end,
  -- bufferId: Returns current buffer id
  bufferId = function()
    return vim.api.nvim_get_current_buf()
  end,
  -- currentLine: Returns the content of the current line
  currentLine = function()
    return vim.api.nvim_get_current_line();
  end,
  -- setCurrentLine: Update the current line
  setCurrentLine = function(newLine)
    vim.api.nvim_set_current_line(newLine)
  end,
  -- position: Returns {line, column} of current position
  position = function()
    local line, column = unpack(vim.api.nvim_win_get_cursor(0))
    return {
      line = line,
      column = column
    }
  end,
}
