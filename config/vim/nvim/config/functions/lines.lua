return {
  -- lineNumber: Returns the current line number
  lineNumber = function()
    return vim.fn.line(".")
  end,
  -- currentLine: Returns the content of the current line
  currentLine = function()
    return vim.api.nvim_get_current_line()
  end,
  -- line: Returns the content of a given line
  line = function(lineNumber)
    return vim.api.nvim_buf_get_lines(0, lineNumber - 1, lineNumber, false)[1]
  end,
  -- forEachLine: Call callback(number, content) for each line of the buffer
  forEachLine = function(callback)
    local lastLineCount = vim.api.nvim_buf_line_count(0)
    for lineNumber = 1, lastLineCount do
      local lineContent = F.line(lineNumber)
      callback(lineNumber, lineContent)
    end
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
      column = column,
    }
  end,
}