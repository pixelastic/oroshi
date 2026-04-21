-- Gotmpl config uses a directory and not a single file like other filetypes because gotmpl
-- needs the html linter, but html need the hasGoTemplateSyntax which creates a
-- circulare dependency if we put them all in the same file
-- So, hasGoTemplateSyntax is in a separate file

local function hasGoTemplateSyntax()
  local allLines = F.lines()
  return F.some(allLines, function(line)
    -- Detect lines that start or end with GoTemplate markers
    local startsWithTemplate = F.startsWith(line, "{{-") or F.startsWith(line, "{{")
    local endsWithTemplate = F.endsWith(line, "-}}") or F.endsWith(line, "}}")

    return startsWithTemplate or endsWithTemplate
  end)
end

return hasGoTemplateSyntax
