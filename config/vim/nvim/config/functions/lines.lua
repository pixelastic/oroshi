return {
  -- line: Returns the content of a line (defaults to current line)
  line = function(lineNumber, bufferId)
    lineNumber = lineNumber or F.lineNumber()
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_lines(bufferId, lineNumber - 1, lineNumber, false)[1]
  end,
  -- updateLine: Update the content of a line (defaults to current line, current buffer)
  updateLine = function(lineNumber, newContent, bufferId)
    lineNumber = lineNumber or F.lineNumber()
    bufferId = bufferId or F.bufferId()
    vim.api.nvim_buf_set_lines(bufferId, lineNumber - 1, lineNumber, false, { newContent })
  end,
  -- lineCount: Returns the number of lines in a buffer (defaults to current buffer)
  lineCount = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_line_count(bufferId)
  end,
  -- allLines: Returns all lines in a buffer (defaults to current buffer)
  allLines = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_lines(bufferId, 0, -1, false)
  end,
  -- forEachLine: Call callback(number, content) for each line (defaults to current buffer)
  forEachLine = function(callback, bufferId)
    bufferId = bufferId or F.bufferId()
    local totalLines = F.lineCount(bufferId)
    for lineNumber = 1, totalLines do
      local lineContent = F.line(lineNumber, bufferId)
      callback(lineNumber, lineContent)
    end
  end,

  -- lineNumber: Returns the current line number
  lineNumber = function()
    return vim.fn.line(".")
  end,
  -- columnNumber: Returns the current column number
  columnNumber = function()
    return vim.fn.col(".")
  end,
  -- position: Returns {line, column} of current position
  position = function()
    return {
      line = F.lineNumber(),
      column = F.columnNumber(),
    }
  end,
}
