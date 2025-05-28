-- Statusline
vim.opt.laststatus = 3 -- One global statusline instead of one per window
vim.opt.showmode = false -- Hide bottom line with mode
vim.opt.statusline = '%!v:lua.__.statusline.main()' -- Use custom function

-- Statusline methods
__.statusline = {
  -- main: What is being passed to vim.opt.statusline
  main = function()
    local statusline = {}

    -- Mode
    local mode = __.statusline.getMode()
    local modeBg = mode.hl.bg; -- Need to be stored statically

    -- Project & file
    local fileData = __.statusline.getFileData()

    -- File
    local file = fileData.file;
    -- Highlight based on file status
    local isReadonly = vim.bo.readonly
    local hasUnsavedChanges = vim.bo.modified
    local isNoName = __.isNoName()
    local fileHighlight = __.vars.statusline.hlFilepathDefault
    if isReadonly then fileHighlight = __.vars.statusline.hlFilepathReadonly end
    if hasUnsavedChanges then fileHighlight = __.vars.statusline.hlFilepathUnsavedChanges end
    if isNoName then fileHighlight = __.vars.statusline.hlFilepathNoName end

    -- Project
    local project = fileData.project;


    local add = __.statusline.add
    -- Mode
    add(statusline, mode.content, mode.hl)
    add(statusline, '', { fg = modeBg, bg = project.hl.bg})

    -- Project
    add(statusline, project.content, project.hl)
    add(statusline, '', { fg = project.hl.bg })

    -- Recording macro
    if __.macro.currentName then
      add(statusline, " 󰑋 ", { fg = 'RED' })
      add(statusline, __.macro.currentName, { fg = 'RED_4' })
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

    local coloredContent = color(content, highlightName)

    __.append(statusline, coloredContent)
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
    if __.statusline.isNvimTree() then
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
        hl = __.vars.statusline.hlNormal,
      },
      i = {
        content = ' INSERT ',
        hl = __.vars.statusline.hlInsert,
      },
      v = {
        content = ' VISUAL ',
        hl = __.vars.statusline.hlVisual,
      },
      s = {
        content = ' SEARCH ',
        hl = __.vars.statusline.hlSearch,
      },
      c = {
        content = ' COMMAND ',
        hl = __.vars.statusline.hlCommand,
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
    local mode = modes[modeKey] or { content = 'UNKNOWN', hl = __.vars.statusline.hlUnknown }

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
    if __.isNoName() then
      rawFilepath = vim.fn.getcwd() .. '/[No Name]'
    end

    -- For NvimTree, we display the current selected folder
    if __.statusline.isNvimTree() then
      rawFilepath = __.nvimtree.currentDirectory
      vim.b.statuslineFileData = nil -- No cache for this buffer
    end

    -- Check in buffer cache first
    if vim.b.statuslineFileData then
      return vim.b.statuslineFileData
    end

    -- Project info
    local projectKey = vim.fn.systemlist(
      'project-by-path ' .. vim.fn.shellescape(rawFilepath)
    )[1]
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

  -- nvimTreeStatusline: Simple statusline for using NvimTree
  nvimTreeStatusline = function()
    local statusline = {}
    local add = __.statusline.add
    add(statusline, '  ', __.vars.statusline.hlNvimTreeSymbol)
    add(statusline, 'TREE ', __.vars.statusline.hlNvimTreeText)
    add(statusline, '', __.vars.statusline.hlNvimTreeSeparator)
    return table.concat(statusline, '')
  end,
}

