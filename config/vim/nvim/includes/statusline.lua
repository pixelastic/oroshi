-- Statusline
vim.opt.laststatus = 2 -- Always display
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.oroshiStatusline()' -- Use custom function


local function refreshStatusLine()
  package.loaded['oroshi.statusline'] = nil
  vim.b.statuslineFileData = nil
  require('oroshi.statusline')
end
nmap('Ⓡ', refreshStatusLine, 'Refresh statusline code')


function oroshiStatusline()
  local statusline = {}

  -- Mode
  local mode = vim.g.statusline.getMode()
  local modeBg = mode.hl.bg; -- Need to be stored statically
  -- Project & file
  local fileData = vim.g.statusline.getFileData()
  local file = fileData.file;
  local project = fileData.project;



  -- Coloring
  local add = vim.g.statusline.add
  -- Mode
  add(statusline, mode.content, mode.hl)
  add(statusline, '', { fg = modeBg, bg = project.hl.bg})

  -- Project
  add(statusline, project.content, project.hl)
  add(statusline, '', { fg = project.hl.bg })

  -- Filepath
  local isReadonly = vim.bo.readonly
  local hasUnsavedChanges = vim.bo.modified
  local fileHighlight = { fg = 'GREEN', bold = true }
  if isReadonly then fileHighlight = { fg = 'RED' } end
  if hasUnsavedChanges then fileHighlight = { fg = 'VIOLET_4' } end
  add(statusline, file.content, fileHighlight)

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
        content = ' NORMAL ',
        hl = { bg = 'BLACK', fg = 'WHITE_LIGHT', bold = true }
      },
      i = {
        content = ' INSERT ',
        hl = { bg = 'YELLOW', fg = 'BLACK', bold = true }
      },
      v = {
        content = ' VISUAL ',
        hl = { bg = 'BLUE', fg = 'WHITE', bold = true }
      },
      s = {
        content = ' SEARCH ',
        hl = { bg = 'ORANGE_7', fg = 'ORANGE_2', bold = true }
      },
      c = {
        content = ' COMMAND ',
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


  -- Get information about current file
  -- Stores info in buffer, so it is only called once per buffer
  -- Usage:
  -- getFileData() 
  -- => { 
  --       project = {
  --         content = 'x oroshi',
  --         hl = {
  --           bg = 'GREEN',
  --           fg = 'WHITE'
  --         }
  --       },
  --       file = {
  --         path = 'config/vim/nvim/includes/statusline.lua',
  --       }
  --   }
  getFileData = function()
    -- Check in buffer cache first
    if vim.b.statuslineFileData then
      return vim.b.statuslineFileData
    end

    local rawFilepath = vim.fn.expand('%:p')

    -- Project info
    local projectKey = vim.fn.systemlist('project-by-path ' .. rawFilepath)[1]
    local projectData = getProject(projectKey)
    local projectContent = ' ' .. projectData.icon .. projectData.name .. ' '
    local project = {
      content = projectContent,
      hl = {
        bg = projectData.bg,
        fg = projectData.fg,
      }
    }

    -- File info
    -- Content
    local fileContent = ' ' .. rawFilepath:gsub(projectData.path, '')
    local file = {
      content = fileContent,
    }


    -- Save in cache
    local statuslineFileData = {
      project = project,
      file = file
    }
    vim.b.statuslineFileData = statuslineFileData
    return statuslineFileData
  end,
}




