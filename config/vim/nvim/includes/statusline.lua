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

  append(statusline, statuslineGetMode())
  append(statusline, statuslineGetProject())

  return table.concat(statusline, '')
end

function statuslineGetMode() 
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

function statuslineGetProject()
  if vim.b.statuslineProject then
    return vim.b.statuslineProject
  end

  local statuslineProject = ''
  local filepath = vim.fn.expand('%:p')
  local projectKey = vim.fn.systemlist('project-by-path ' .. filepath)[1]

  return projectKey
--   let filepath = expand('%:p')
--   let projectKey = StrTrim(system('project-by-path ' . filepath))
--   let projectName = tolower(projectKey)



-- " Returns a string representation of the project
-- " - Colored based on colors in PROJECT_
-- " - With an icon matching the extension
-- " - With the filetype as detected by vim if different
-- function! StatusLineGetProject()
--   " Disable in vim-plug update window
--   if &filetype ==# 'vim-plug'
--     return
--   endif
--
--   let filepath = expand('%:p')
--   let projectKey = StrTrim(system('project-by-path ' . filepath))
--   let projectName = tolower(projectKey)
--
--   " vint: -ProhibitUsingUndeclaredVariable
--   silent! execute 'let icon=$PROJECT_' . projectKey . '_ICON'
--   silent! execute 'let shouldHideName=$PROJECT_' . projectKey . '_HIDE_NAME_IN_PROMPT'
--   " Failsafe if the above commands don't work (maybe because I messed up my
--   " project listing file)
--   if !exists('icon')
--     return ""
--   endif
--
--   let projectStatus=''
--   let projectStatus.='%#ProjectPre_' . projectKey . '# %*'
--   let projectStatus.='%#Project_' . projectKey . '#' . icon
--   if shouldHideName ==# '0'
--     let projectStatus.=projectName
--   endif
--   let projectStatus.=' %*'
--   let projectStatus.='%#ProjectPost_' . projectKey . '#%*'
--   " vint: +ProhibitUsingUndeclaredVariable
--   "
--   return projectStatus
-- endfunction
end



