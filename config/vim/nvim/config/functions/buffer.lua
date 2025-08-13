return {
  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand("%") == ""
  end,
  -- bufferId: Returns current buffer id
  bufferId = function()
    return vim.api.nvim_get_current_buf()
  end,
  -- newBuffer: Creates a new buffer
  newBuffer = function()
    -- Note: false, true means: unlisted, scratch (ie. not saveable)
    return vim.api.nvim_create_buf(false, true)
  end,
  -- deleteBuffer: Delete a given buffer
  deleteBuffer = function(bufferId)
    vim.api.nvim_buf_delete(bufferId, { force = true })
  end,
  -- lineNumber: Returns the current line number
  lineNumber = function()
    return vim.fn.line(".")
  end,
  -- currentLine: Returns the content of the current line
  currentLine = function()
    return vim.api.nvim_get_current_line()
  end,
  -- getLine: Returns the content of a given line
  getLine = function(lineNumber)
    return vim.api.nvim_buf_get_lines(0, lineNumber - 1, lineNumber, false)[1]
  end,
  -- forEachLine: Call callback(number, content) for each line of the buffer
  forEachLine = function(callback)
    local lastLineCount = vim.api.nvim_buf_line_count(0)
    for lineNumber = 1, lastLineCount do
      local lineContent = F.getLine(lineNumber)
      callback(lineNumber, lineContent)
    end
  end,
  -- setCurrentLine: Update the current line
  setCurrentLine = function(newLine)
    vim.api.nvim_set_current_line(newLine)
  end,
  -- getBufferOption: Return the value of a specific buffer option
  getBufferOption = function(bufferId, optionName)
    return vim.api.nvim_get_option_value(optionName, { buf = bufferId })
  end,
  -- getBufferLines: Returns a collection of all lines in a buffer
  getBufferLines = function(bufferId)
    return vim.api.nvim_buf_get_lines(bufferId, 0, -1, false)
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
