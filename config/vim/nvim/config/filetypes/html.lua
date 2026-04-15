local M = {}

M.onFiletype = function()
  F.imap("<C-E>", M.expandEmmet, "Expand Emmet abbreviation")
  F.imap("<C-:>", "</<C-X><C-O>", "Close current HTML tag")
end

M.configureLinter = function(lint)
  lint.linters.oroshi_html_lint = {
    cmd = "html-lint",
    stdin = false,
    args = {},
    ignore_exitcode = true,
    parser = M.lintParser,
  }
end

M.configureFormatter = function(conform)
  conform.formatters.oroshi_html_fix = {
    command = "html-fix",
    stdin = true,
    args = { "--piped", "--filepath", "$FILENAME" },
    exit_codes = { 0, 1 },
  }
end

-- Parser to convert djlint CLI output to diagnostics
-- djlint format:
-- H025 1:18 Tag seems to be an orphan. <p>
M.lintParser = function(output)
  local diagnostics = {}
  local lines = vim.split(output, "\n")

  for _, line in ipairs(lines) do
    -- Match pattern: CODE LINE:COLUMN MESSAGE
    local code, row, col, message = line:match("^(%S+)%s+(%d+):(%d+)%s+(.+)$")
    if code and row and col and message then
      table.insert(diagnostics, {
        lnum = tonumber(row) - 1,
        col = tonumber(col) - 1,
        severity = vim.diagnostic.severity.ERROR,
        message = message,
        source = "djlint",
        code = code,
      })
    end
  end

  return diagnostics
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
