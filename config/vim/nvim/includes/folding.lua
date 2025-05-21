vim.opt.foldlevel = 3 -- Some folds opened by default
vim.opt.fillchars = "fold: "  -- Pad with spaces

-- Custom foldtext method
vim.opt.foldtext='v:lua.oroshiFoldText()'
function oroshiFoldText()
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


