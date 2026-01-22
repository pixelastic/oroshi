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
  replaceLines = function(userLines, position, bufferId)
    -- Default to current line
    local currentLine = F.lineNumber()
    if position == nil then
      position = { currentLine, currentLine }
    end
    -- Accepte position as a single line
    if F.isString(position) or F.isNumber(position) then
      position = { position, position }
    end
    -- Make the end default to the start
    if not position[2] then
      position[2] = position[1]
    end

    bufferId = bufferId or F.bufferId()

    -- Convert single lines to array
    local lines = F.isString(userLines) and F.split(userLines, "\n") or userLines

    vim.api.nvim_buf_set_lines(bufferId, position[1] - 1, position[2], false, lines)
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
  -- moveTo: Move cursor to specified line and column (defaults to current split)
  moveTo = function(lineNumber, columnNumber, splitId)
    splitId = splitId or F.splitId()
    columnNumber = columnNumber or 1
    vim.api.nvim_win_set_cursor(splitId, { lineNumber, columnNumber - 1 })
  end,
}
