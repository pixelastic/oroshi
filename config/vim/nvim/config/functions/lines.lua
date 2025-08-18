return {
  -- line: Returns the content of a line (defaults to current line)
  line = function(lineNumber, bufferId)
    lineNumber = lineNumber or F.lineNumber()
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_lines(bufferId, lineNumber - 1, lineNumber, false)[1]
  end,
  -- lines: Returns all lines in a buffer (defaults to current buffer)
  lines = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_lines(bufferId, 0, -1, false)
  end,
  -- updateLine: Update the content of a line (defaults to current line, current buffer)
  updateLine = function(newContent, lineNumber, bufferId)
    lineNumber = lineNumber or F.lineNumber()
    bufferId = bufferId or F.bufferId()
    vim.api.nvim_buf_set_lines(bufferId, lineNumber - 1, lineNumber, false, { newContent })
  end,
  -- lineCount: Returns the number of lines in a buffer (defaults to current buffer)
  lineCount = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_line_count(bufferId)
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
  -- position: Returns {line, column} of cursor position (defaults to current split)
  position = function(splitId)
    splitId = splitId or F.splitId()
    local cursor = vim.api.nvim_win_get_cursor(splitId)
    return {
      line = cursor[1],
      column = cursor[2] + 1, -- Convert 0-based to 1-based
    }
  end,
  -- lineNumber: Returns the line number of cursor (defaults to current split)
  lineNumber = function(splitId)
    return F.position(splitId).line
  end,
  -- columnNumber: Returns the column number of cursor (defaults to current split)
  columnNumber = function(splitId)
    return F.position(splitId).column
  end,
}
