local M = {}

M.onFiletype = function()
  F.imap("<C-E>", M.expandEmmet, "Expand Emmet abbreviation")
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_html_fix = {
    command = "html-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
    timeout_ms = 10000,
  }
end

M.expandEmmet = function()
  -- Note: This currently considers the last word as the abbrev, and replaces
  -- the whole line

  -- Getting the abbreviation
  local currentLine = F.line()
  local splits = F.split(currentLine, " ")
  local abbr = F.last(splits)
  if not abbr then
    return
  end

  -- Getting the snippet
  local filetype = F.option("filetype")
  local snippet = vim.fn["emmet#expandWord"](abbr, filetype, 0)
  if not snippet then
    return
  end

  -- Replace the current line with the indented snippet
  F.replaceLines(snippet)

  -- Indent newly added snippet
  local startLineNumber = F.lineNumber()
  local snippetLines = F.split(snippet, "\n")
  local endLineNumber = startLineNumber + F.length(snippetLines) - 1
  F.indent(startLineNumber, endLineNumber)

  -- Move cursor back to first line
  local startLineContent = F.line(startLineNumber)
  local startColumnNumber = F.length(startLineContent)
  F.normalMode()
  F.moveTo(startLineNumber, startColumnNumber + 1)
end

return M
