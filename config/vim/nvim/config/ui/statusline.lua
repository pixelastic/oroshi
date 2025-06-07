local hl = F.hl


-- Statusline
vim.opt.laststatus = 3 -- One global statusline instead of one per window
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.O_STATUSLINE.main()' -- Use custom function

-- Statusline methods
O_STATUSLINE = {
  -- main: What is being passed to vim.opt.statusline
  main = function()
    local add = O_STATUSLINE.add
    local statusline = {}

    -- Mode
    local mode = O_STATUSLINE.getMode()
    local modeBg = mode.hl.bg; -- Need to be stored statically

    -- Project & file
    local fileData = O_STATUSLINE.getFileData()

    -- File
    local file = fileData.file;
    -- Highlight based on file status
    local isReadonly = vim.bo.readonly
    local hasUnsavedChanges = vim.bo.modified
    local isNoName = F.isNoName()
    local fileHighlight = O.colors.statusline.filepathDefault
    if isReadonly then fileHighlight = O.colors.statusline.filepathReadonly end
    if hasUnsavedChanges then fileHighlight = O.colors.statusline.filepathUnsavedChanges end
    if isNoName then fileHighlight = O.colors.statusline.filepathNoName end

    -- Project
    local project = fileData.project;


    -- Mode
    add(statusline, mode.content, mode.hl)
    add(statusline, '', { fg = modeBg, bg = project.hl.bg})

    -- Project
    add(statusline, project.content, project.hl)
    add(statusline, '', { fg = project.hl.bg })

    -- Recording macro
    if O.statusline.macroName then
      add(statusline, " 󰑋 ", { fg = 'RED' })
      add(statusline, O.statusline.macroName, { fg = 'RED_4' })
    end

    -- Filepath
    add(statusline, file.content, fileHighlight)

    -- Separator
    add(statusline, '%<%=')

    local fileencoding = vim.bo.fileencoding ~= '' and vim.bo.fileencoding or vim.o.encoding
    local filetype = vim.bo.filetype
    -- Copilot
    local isCopilotLoaded = O.statusline.copilotLoaded
    local isCopilotDisabled = vim.b.statuslineCopilotDisabled
    local copilotColor = O.colors.statusline.copilotEnabled
    if not isCopilotLoaded then copilotColor = O.colors.statusline.copilotNotLoaded end
    if isCopilotDisabled then copilotColor = O.colors.statusline.copilotDisabled end

    -- File encoding (only if not UTF-8)
    if fileencoding ~= 'utf-8' then
      add(statusline, ' ' .. fileencoding, { fg = 'RED' })
    end

    -- Copilot
    add(statusline, '', { bg = 'GRAY_8', fg = copilotColor.bg })
    add(statusline, '   ' , copilotColor)

    -- Filetype
    add(statusline, '', { fg = 'GRAY_9', bg = copilotColor.bg })
    add(statusline, ' ' .. filetype .. ' ', { bg = 'GRAY_9', fg = 'WHITE' })

    -- Foldmarker
    -- local foldmethod = vim.wo.foldmethod
    -- local foldSymbolMap = { manuel = 'M', marker = '{', syntax = 'S', indent = '▸', expr = '󰊕 ' }
    -- local foldSymbol = foldSymbolMap[foldmethod] or '?'
    -- add(statusline, '  ' .. foldSymbol)

    -- Ruler
    -- add(statusline, '  %2.c:%2.l %2p%%')
    -- add(statusline, '  0x%2.B')

    return table.concat(statusline, '')
  end,

  -- add: Add an element to the statusline
  add = function(statusline, content, highlight)
    -- Usage :
    -- add(statusline, ' NORMAL ', { bg = 'BLACK', fg = 'WHITE' })
    if not highlight then highlight = {} end

    -- Define a highlight group based on the "slot" in the statusbar
    local slotNumber = #statusline + 1
    local highlightName = 'StatuslineSlot' .. slotNumber
    hl(highlightName, 'none', highlight)

    local coloredContent = F.color(content, highlightName)

    F.append(statusline, coloredContent)
  end,

  -- getMode: Get informations about current mode
  getMode = function()
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

    -- NvimTree mode
    if O_STATUSLINE.isNvimTree() then
      return {
        content = '  ',
        hl = {
          bg = 'GREEN_9',
          fg = 'YELLOW'
        }
      }
    end

    -- All regular modes
    local modes = {
      n = {
        content = ' NORMAL ',
        hl = O.colors.statusline.normal,
      },
      i = {
        content = ' INSERT ',
        hl = O.colors.statusline.insert,
      },
      v = {
        content = ' VISUAL ',
        hl = O.colors.statusline.visual,
      },
      s = {
        content = ' SEARCH ',
        hl = O.colors.statusline.search,
      },
      c = {
        content = ' COMMAND ',
        hl = O.colors.statusline.command,
      },
    }

    -- Guess current mode
    local modeKey = vim.fn.mode()
    if F.isVisualMode() then
      -- All visual selection (grid or full line) are visual
      modeKey = 'v'
    end
    if F.isSearchMode() then
      -- Dissociate command (:) from search (/)
      modeKey = 's'
    end

    -- Pick right mode
    local mode = modes[modeKey] or { content = 'UNKNOWN', hl = O.colors.statusline.unknown }

    return mode
  end,

  -- getFileData: Get information about current file
  getFileData = function()
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
    --         content = 'config/vim/…/statusline.lua',
    --         basename = 'statusline.lua'
    --       }
    --   }

    -- Which file to check?
    local rawFilepath = vim.fn.expand('%:p')

    -- For a [No Name] buffer
    if F.isNoName() then
      rawFilepath = vim.fn.getcwd() .. '/[No Name]'
    end

    -- For NvimTree, we display the current selected folder
    if O_STATUSLINE.isNvimTree() then
      rawFilepath = O.nvimtree.currentDirectory
      vim.b.statuslineFileData = nil -- No cache for this buffer
    end

    -- For healthcheck
    if O_STATUSLINE.isHealtcheck() then
      return {
        file = { content = "" },
        project = {
          content = "   healthcheck ",
          hl = { bg = "RED_LIGHT", fg = "WHITE" }
        }
      }
    end

    -- Check in buffer cache first
    if vim.b.statuslineFileData then
      return vim.b.statuslineFileData
    end

    -- Project info
    local projectKey = vim.fn.systemlist(
      'project-by-path ' .. vim.fn.shellescape(rawFilepath)
    )[1]
    local projectData = F.getProjectData(projectKey)
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

    -- Filepath
    local relativePath = rawFilepath:gsub('^' .. projectData.path, '')
    local basename = vim.fs.basename(rawFilepath)
    local simplifiedPath = vim.fn.systemlist(
      'simplify-path ' .. vim.fn.shellescape(relativePath) .. ' 3' -- Keep only three levels
    )[1]
    local fileContent = ' ' .. simplifiedPath
    local file = {
      content = fileContent,
      basename = basename,
    }


    -- Save in cache
    local statuslineFileData = {
      project = project,
      file = file
    }
    vim.b.statuslineFileData = statuslineFileData
    return statuslineFileData
  end,

  -- isNvimTree: Check if in a nvim tree window
  isNvimTree = function()
    return vim.bo.filetype == 'NvimTree'
  end,

  -- isHealthcheck: Check if in a healthcheck window
  isHealtcheck= function()
    return vim.bo.filetype == 'checkhealth'
  end,

  -- nvimTreeStatusline: Simple statusline for using NvimTree
  nvimTreeStatusline = function()
    local statusline = {}
    local add = O_STATUSLINE.add
    add(statusline, '  ', O.colors.statusline.nvimTreeSymbol)
    add(statusline, 'TREE ', O.colors.statusline.nvimTreeText)
    add(statusline, '', O.colors.statusline.nvimTreeSeparator)
    return table.concat(statusline, '')
  end,
}
