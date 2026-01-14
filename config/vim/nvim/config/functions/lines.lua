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
  -- addLines: Add one or more lines (pushing the next ones down)
  addLines = function(userLines, lineNumber, bufferId)
    lineNumber = lineNumber or F.lineNumber()
    bufferId = bufferId or F.bufferId()

    -- Convert single lines to array
    local lines = F.isString(userLines) and F.split(userLines, "\n") or userLines

    vim.api.nvim_buf_set_lines(bufferId, lineNumber - 1, lineNumber - 1, false, lines)
  end,
  -- replaceLines: Replace one or more lines
  replaceLines = function(userLines, startLine, endLine, bufferId)
    -- If endLine is not provided, replace single line
    if type(endLine) == "number" then
      bufferId = bufferId or F.bufferId()
    else
      bufferId = endLine or F.bufferId()
      endLine = startLine
    end
    startLine = startLine or F.lineNumber()

    -- Convert single lines to array
    local lines = F.isString(userLines) and F.split(userLines, "\n") or userLines

    vim.api.nvim_buf_set_lines(bufferId, startLine - 1, endLine, false, lines)
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
