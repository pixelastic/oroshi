local nmap = F.nmap
local ftplugin = F.ftplugin

vim.opt.foldmethod = 'marker'   -- Fold on markers by default
vim.opt.foldmarker = '{{{,}}}'  -- markers to use
vim.opt.foldlevel = 99
vim.opt.fillchars = "fold: "  -- Pad with spaces
vim.opt.foldtext='v:lua.O_FOLDTEXT()' -- Method to display fold recap line

-- Use treesitter for folding specific files
ftplugin(
  { "bash", "css", "csv", "dockerfile", "editorconfig", "html",
    "ini", "javascript", "json", "lua", "markdown", "nginx", "pug",
    "ruby", "xml", "yaml" },
  function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
)


-- Custom foldtext method
O_FOLDTEXT = function()
  local prefixSymbol = ''
  local firstLine = vim.fn.getline(vim.v.foldstart)
  local firstChar = firstLine:sub(1, 1)

  -- Just return the line if I don't have enough space to add the marker
  if firstChar ~= ' ' then
    return firstLine
  end

  return prefixSymbol .. firstLine:sub(2)
end

-- Open folds to a certain level
local function setFoldLevel(level)
  return function()
    vim.opt_local.foldlevel = level
  end
end
nmap('z&', setFoldLevel(1), 'Set fold level to 1')
nmap('zé', setFoldLevel(2), 'Set fold level to 2')
nmap('z"', setFoldLevel(3), 'Set fold level to 3')
nmap("z'", setFoldLevel(4), 'Set fold level to 4')
nmap('z(', setFoldLevel(5), 'Set fold level to 5')
nmap('z-', setFoldLevel(6), 'Set fold level to 6')
nmap('zè', setFoldLevel(7), 'Set fold level to 7')
nmap('z_', setFoldLevel(8), 'Set fold level to 8')
nmap('zç', setFoldLevel(9), 'Set fold level to 9')
nmap('zà', setFoldLevel(0), 'Set fold level to 0')

-- Toggle fold under cursor
local function toggleFold()
  -- Wrap in a pcall() to prevent errors if
  local _, error = pcall(function()
    vim.cmd('normal! za')
  end)
  if error then
    F.debug('No fold found')
  end
end
nmap('za', toggleFold, 'Toggle fold')




