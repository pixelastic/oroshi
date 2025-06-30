vim.opt.foldenable = true
vim.opt.foldtext='v:lua.O.folding.text()' -- Method to display fold recap line
vim.opt.foldlevel = 99
vim.opt.fillchars = "fold: "  -- Pad with spaces

-- Fold on markers by default, but also on expr if treesitter is available
vim.opt.foldmethod = 'marker'
vim.opt.foldmarker = '{{{,}}}'
F.ftplugin(
  { "bash", "css", "csv", "dockerfile", "editorconfig", "html",
    "ini", "javascript", "json", "lua", "markdown", "nginx", "pug",
    "ruby", "xml", "yaml" },
  function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr='v:lua.O.folding.expr()'
  end
)

-- Status marking if line is between manual markers
O.folding.isInMarker = false;

-- expr: Fold expression
-- Note: It is assumed that nvim will call this method for every line in the
-- file, in order, setting vim.v.lnum to the line being checked
O.folding.expr = function()
  local level = O.folding.getFoldDetails(vim.v.lnum)
  return level.expr
end

-- getFoldDetails: Returns fold details about the specified line number
O.folding.getFoldDetails = function(lineNumber)
  -- treesitter
  local line = vim.fn.getline(lineNumber)
  local treesitterLevel = vim.treesitter.foldexpr(lineNumber)

  -- markers
  local isOpeningMarker = line:find("{{{", 1, true)
  local isClosingMarker = line:find("}}}", 1, true)
  local isInMarker = O.folding.isInMarker and not isOpeningMarker and not isClosingMarker

  -- incrementExpr: Increment an expr (like 5 or >4) by one level
  local incrementExpr = function(expr)
    local isStart = F.startsWith(expr, '>')
    local currentLevel = tonumber('' .. F.replace(expr, '>', '')) or 0
    local nextLevel = currentLevel + 1

    if isStart then
      return '>' .. nextLevel
    else
      return '' .. nextLevel
    end
  end

  -- Updating expr based on where the markers are
  local expr = treesitterLevel
  if isOpeningMarker then
    expr = '>' .. incrementExpr(treesitterLevel)
    O.folding.isInMarker = true
  end

  if isInMarker then
    expr = incrementExpr(treesitterLevel)
  end

  if isClosingMarker then
    expr = incrementExpr(treesitterLevel)
    O.folding.isInMarker = false
  end

  return {
    isOpeningMarker = isOpeningMarker,
    isInMarker = isInMarker,
    isClosingMarker = isClosingMarker,
    treesitter = treesitterLevel,
    expr = expr
  }
end

-- debug: Display fold level information
O.folding.debug = function()
  -- Setup
  local bufferId = F.bufferId()
  local namespace = vim.api.nvim_create_namespace("FoldingDebug")

  -- Clear previous virtual texts
  vim.api.nvim_buf_clear_namespace(bufferId, namespace, 0, -1)

  -- getDebugInfo: Returns a normalized string and hlGroup for the expr
  local getDebugInfo = function(expr)
    local isStart = F.startsWith(expr, '>')

    -- title
    local title = expr
    if not isStart then title = ' ' .. title end

    -- level
    local levelAsString = F.replace(expr, '>', '')
    local level = tonumber(levelAsString) or 0

    -- normalized title
    local maxWidth = 10
    local prefix = string.rep(" ", level)
    local suffix = string.rep(" ", maxWidth - F.length(prefix) - F.length(title))

    -- return value
    local content = prefix .. title .. suffix
    local hlGroup = "FoldDebugLevel" .. level
    return {
      content = content,
      hlGroup = hlGroup
    }
  end


  -- Add on each line
  F.forEachLine(function(lineNumber)
    local foldLevel = O.folding.getFoldDetails(lineNumber)

    -- treesitter
    local treesitterDisplay = getDebugInfo(foldLevel.treesitter)

    -- markers
    local markerSign = " "
    if foldLevel.isOpeningMarker then markerSign = "{" end
    if foldLevel.isInMarker      then markerSign = "=" end
    if foldLevel.isClosingMarker then markerSign = "}" end

    -- expr
    local exprDisplay = getDebugInfo(foldLevel.expr)

    vim.api.nvim_buf_set_extmark(bufferId, namespace, lineNumber - 1, 0, {
      virt_text = {
        { treesitterDisplay.content, treesitterDisplay.hlGroup },
        { ' ' .. markerSign .. ' ',     "FoldDebugMarker" },
        { exprDisplay.content, exprDisplay.hlGroup },
      },
      virt_text_pos = "right_align",
      hl_mode = "combine",
    })
  end)
end


-- text: Text to display when folded
O.folding.text = function()
  local prefixSymbol = ''
  local firstLine = vim.fn.getline(vim.v.foldstart)
  local firstChar = firstLine:sub(1, 1)

  -- Just return the line if I don't have enough space to add the marker
  if firstChar ~= ' ' then
    return firstLine
  end

  return prefixSymbol .. firstLine:sub(2)
end

-- toggle: Toggle fold under cursor
O.folding.toggle = function()
  -- Wrap in a pcall() to prevent errors if
  local _, error = pcall(function()
    vim.cmd('normal! za')
  end)

  if error then
    F.warn('No fold found')
  end
end

-- setLevel: Set the current fold level in the buffer
O.folding.setLevel = function(level)
  return function()
    vim.opt_local.foldlevel = level
  end
end


-- Toggle fold
F.nmap('za', O.folding.toggle, 'Toggle fold')
-- Open folds to a certain level
F.nmap('z&', O.folding.setLevel(1), 'Set fold level to 1')
F.nmap('zé', O.folding.setLevel(2), 'Set fold level to 2')
F.nmap('z"', O.folding.setLevel(3), 'Set fold level to 3')
F.nmap("z'", O.folding.setLevel(4), 'Set fold level to 4')
F.nmap('z(', O.folding.setLevel(5), 'Set fold level to 5')
F.nmap('z-', O.folding.setLevel(6), 'Set fold level to 6')
F.nmap('zè', O.folding.setLevel(7), 'Set fold level to 7')
F.nmap('z_', O.folding.setLevel(8), 'Set fold level to 8')
F.nmap('zç', O.folding.setLevel(9), 'Set fold level to 9')
F.nmap('zà', O.folding.setLevel(0), 'Set fold level to 0')
-- Show fold debug levels
F.nmap('<F32>', O.folding.debug, 'Show fold debug info') -- C-F8
