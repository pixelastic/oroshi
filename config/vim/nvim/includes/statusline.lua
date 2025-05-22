-- Statusline
vim.opt.laststatus = 2 -- Always display
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.oroshiStatusline()' -- Use custom function


local token = math.random(1, 1000)
local function refreshStatusLine()
  package.loaded['oroshi.statusline'] = nil
  require('oroshi.statusline')
end
nmap('Ⓡ', refreshStatusLine, 'Refresh statusline code')




function oroshiStatusline()
  local statusline = {}

  append(statusline, getMode())

  return table.concat(statusline, ' / ')
end

function getMode() 
  local rawMode = vim.fn.mode()
  local modeNames = {
    n = 'Normal',
    i = 'Insert',
    v = 'Visual',
    V = 'Visual',
    [''] = 'Visual',
    c = 'Command'
  }
  local modeName = modeNames[rawMode] or 'Unknown'

  -- Search mode is a submode of command
  if modeName == 'Command' then
    local commandType = vim.fn.getcmdtype()
    if commandType == '/' then
      modeName = 'Search'
    end
  end

  -- Transform modeName into highlighted element
  local ret = color(' '..modeName:upper()..' ', 'StatuslineMode' .. modeName)
  ret = ret .. color('', 'StatuslineMode' .. modeName .. 'Separator')

  return ret
end

