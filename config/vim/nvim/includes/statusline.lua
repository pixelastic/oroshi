-- Statusline
vim.opt.laststatus = 2 -- Always display
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.oroshiStatusline()' -- Use custom function


local function refreshStatusLine()
  package.loaded['oroshi.statusline'] = nil
  require('oroshi.statusline')
end
nmap('Ⓡ', refreshStatusLine, 'Refresh statusline code')


function oroshiStatusline()
  local statusline = {}

  local mode = vim.g.statusline.getMode()
  local modeBg = mode.hl.bg; -- Need to be stored statically

  local project = vim.g.statusline.getProject()
  local projectBg = project.hl.bg;


  local add = vim.g.statusline.add
  add(statusline, ' ' .. mode.content .. ' ', mode.hl)
  add(statusline, '', { fg = modeBg, bg = projectBg })
  add(statusline, ' ' .. project.display .. ' ', project.hl)
  add(statusline, '', { fg = projectBg })

  return table.concat(statusline, '')
end

vim.g.statusline = {
  -- Add an element to the statusline
  -- Usage:
  -- add(statusline, ' NORMAL ', { bg = 'BLACK', fg = 'WHITE' })
  add = function(statusline, content, highlight)
    if not highlight then highlight = {} end

    -- Define a highlight group based on the "slot" in the statusbar
    local slotNumber = #statusline + 1
    local highlightName = 'StatuslineSlot' .. slotNumber
    hl(highlightName, 'none', highlight)

    local coloredContent = color(content, highlightName)

    append(statusline, coloredContent)
  end,

  -- Get informations about current mode
  -- Usage:
  -- getMode() 
  -- => { 
  --     content = 'NORMAL', 
  --     hl = { 
  --       bg = 'BLACK', 
  --       fg = 'WHITE_LIGHT,
  --       bold = true
  --     }
  --   }
  getMode = function() 
    -- All possible modes
    local modes = {
      n = {
        content = 'NORMAL',
        hl = { bg = 'BLACK', fg = 'WHITE_LIGHT', bold = true }
      },
      i = {
        content = 'INSERT',
        hl = { bg = 'YELLOW', fg = 'BLACK', bold = true }
      },
      v = {
        content = 'VISUAL',
        hl = { bg = 'BLUE', fg = 'WHITE', bold = true }
      },
      s = {
        content = 'SEARCH',
        hl = { bg = 'ORANGE_7', fg = 'ORANGE_2', bold = true }
      },
      c = {
        content = 'COMMAND',
        hl = { bg = 'TEAL', fg = 'TEAL_1', bold = true }
      },
    }

    -- Guess current mode
    local modeKey = vim.fn.mode()
    if (modeKey == 'V' or modeKey == '') then
      -- All visual selection (grid or full line) are visual
      modeKey = 'v'
    end
    if modeKey == 'c' and vim.fn.getcmdtype() == '/' then
      -- Dissociate command (:) from search (/)
      modeKey = 's'
    end

    -- Pick right mode
    local mode = modes[modeKey] or { content = 'UNKNOWN', hl = { bg = 'CYAN'} }

    return mode
  end,

  -- Get information about current project
  -- Stores info in buffer, so it is only called once per buffer
  -- Usage:
  -- getProject() 
  -- => { 
  --       display = 'x oroshi',
  --       name = 'oroshi',
  --       icon = 'x ',
  --       hl = {
  --         bg = 'GREEN',
  --         fg = 'WHITE'
  --       }
  --   }
  getProject = function()
    if vim.b.statuslineProject then
      return vim.b.statuslineProject
    end

    local filepath = vim.fn.expand('%:p')
    local projectKey = vim.fn.systemlist('project-by-path ' .. filepath)[1]
    local project = getProject(projectKey)

    local display = project.icon .. project.name

    return {
      display = display,
      name = project.name,
      icon = project.icon,
      hl = {
        bg = project.bg,
        fg = project.fg,
      }
    }
  end

}




