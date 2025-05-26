-- Statusline
vim.opt.laststatus = 3 -- One global statusline instead of one per window
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.oroshiStatusline()' -- Use custom function

function oroshiStatusline()
  local statusline = {}

  -- Nvim-Specific statusline
  if vim.bo.filetype == 'NvimTree' then
    return vim.g.statusline.nvimTreeStatusline()
  end

  -- Mode
  local mode = vim.g.statusline.getMode()
  local modeBg = mode.hl.bg; -- Need to be stored statically
  -- Project & file
  local fileData = vim.g.statusline.getFileData()
  -- File
  local file = fileData.file;
  local isReadonly = vim.bo.readonly
  local hasUnsavedChanges = vim.bo.modified
  local fileHighlight = { fg = 'GREEN', bold = true }
  if isReadonly then fileHighlight = { fg = 'RED' } end
  if hasUnsavedChanges then fileHighlight = { fg = 'VIOLET_4' } end
  -- Project
  local project = fileData.project;


  local add = vim.g.statusline.add
  -- Mode
  add(statusline, mode.content, mode.hl)
  add(statusline, '', { fg = modeBg, bg = project.hl.bg})

  -- Project
  add(statusline, project.content, project.hl)
  add(statusline, '', { fg = project.hl.bg })

  -- Recording macro
  if vim.g.recordingMacro then
    add(statusline, " 󰑋 ", { fg = 'RED' })
    add(statusline, vim.g.recordingMacro, { fg = 'RED_4' })
  end

  -- Filepath
  add(statusline, file.content, fileHighlight)

  -- Separator
  add(statusline, '%<%=')


  -- File encoding (only if not UTF-8)
  local fileencoding = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
  if fileencoding ~= 'utf-8' then
    add(statusline, ' ' .. fileencoding, { fg = 'RED' })
  end

  -- Filetype
  local filetype = vim.bo.filetype
  add(statusline, ' ' .. filetype)

  -- Foldmarker
  local foldmethod = vim.wo.foldmethod
  local foldSymbolMap = { manuel = 'M', marker = '{', syntax = 'S', indent = '▸', expr = '󰊕 ' }
  local foldSymbol = foldSymbolMap[foldmethod] or '?'
  add(statusline, '  ' .. foldSymbol)

  -- Ruler
  add(statusline, '  %2.c:%2.l %2p%%')
  add(statusline, '  0x%2.B')


  return table.concat(statusline, '')
end

vim.g.statusline = {
  -- Add an element to the statusline
  -- Usage :
  -- add(statusline, ' NORMAL ', { bg = 'BLACK', fg = 'WHITE' })
  add = function(statusline, content, highlight)
    if not highlight then highlight = {} end

    -- Define a highlight group based on the "slot" in the statusbar
    local slotNumber = #statusline + 1
    local highlightName = 'StatuslineSlot' .. slotNumber
    hl(highlightName, 'none', highlight)

    local coloredContent = color(content, highlightName)

    __.append(statusline, coloredContent)
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
    -- Icon with name string
    local projectContent = projectData.icon
    if projectData.hideNameInPrompt == '0' then
      projectContent = projectContent .. projectData.name
    end
    local project = {
      content = ' ' .. projectContent .. ' ',
      hl = {
        bg = projectData.bg,
        fg = projectData.fg,
      }
    }

    -- File info
    -- Content
    local relativePath = rawFilepath:gsub('^' .. projectData.path, '')
    local simplifiedPath = vim.fn.systemlist('simplify-path ' .. relativePath .. ' 3')[1] -- Keep only three levels
    local fileContent = ' ' .. simplifiedPath
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


  -- nvimTreeStatusline: Simple statusline for using NvimTree
  nvimTreeStatusline = function()
    local statusline = {}
    local add = vim.g.statusline.add
    add(statusline, '  ', { fg= 'YELLOW', bg = 'GREEN_9' })
    add(statusline, 'TREE ', { fg= 'WHITE', bg = 'GREEN_9' })
    add(statusline, '', { fg = 'GREEN_9' })
    return table.concat(statusline, '')
  end,

}

-- Switch a boolean when recording a macro
local function setIsRecording(status)
  return function()
    if status then
      vim.g.recordingMacro = vim.fn.reg_recording()
    else
      vim.g.recordingMacro = false
    end

    vim.cmd("redrawstatus")
  end
end
autocmd('RecordingEnter', '*', setIsRecording(true))
autocmd('RecordingLeave', '*', setIsRecording(false))
