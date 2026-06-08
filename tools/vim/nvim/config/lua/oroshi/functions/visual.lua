return {
  -- getSelection: Returns the current selected text
  getSelection = function()
    local range = F.getRange()
    return vim.api.nvim_buf_get_text(
      range.bufferId,
      range.startLine - 1,
      range.startColumn - 1,
      range.endLine - 1,
      range.endColumn,
      {}
    )
  end,

  -- replaceSelection: Replace the currently selected text with the new text
  replaceSelection = function(newContent)
    -- Accepts collection of lines, or single line
    if not F.isCollection(newContent) then
      newContent = { newContent }
    end

    local range = F.getRange()
    vim.api.nvim_buf_set_text(
      range.bufferId,
      range.startLine - 1,
      range.startColumn - 1,
      range.endLine - 1,
      range.endColumn,
      newContent
    )

    F.normalMode()
  end,

  -- getRange: Returns normalized bufferId, startLine, endLine, startColumn and endColumn
  getRange = function()
    local bufferId, startLine, startColumn = unpack(vim.fn.getpos("v"))
    local _, endLine, endColumn = unpack(vim.fn.getpos("."))

    -- Ensure the selection is normalized (startLine <= endLine)
    if startLine > endLine or (startLine == endLine and startColumn > endColumn) then
      startLine, endLine = endLine, startLine
      startColumn, endColumn = endColumn, startColumn
    end

    -- If in visual line mode, we extend the start/end columns to the full line
    if F.isVisualLineMode() then
      startColumn = 1
      endColumn = F.line(endLine):len()
    end

    return {
      bufferId = bufferId,
      startLine = startLine,
      endLine = endLine,
      startColumn = startColumn,
      endColumn = endColumn,
    }
  end,

  -- selectWord: Select current word
  selectWord = function()
    vim.cmd.normal("viW")
  end,

  -- selectLine: Select current line
  selectLine = function()
    vim.cmd.normal("V")
  end,
}
