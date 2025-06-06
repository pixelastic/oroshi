return {
  -- hl: Define colors for a specific highlight group
  -- Usage:
  -- hl('Comment', 'RED')                                 -- Foreground color only
  -- hl('Comment', 'RED', { bg = 'GREEN' })               -- Also background
  -- hl('Comment', 'RED', { bold = true })                -- Also bold
  -- hl('Comment', 'RED', { blend = 100 })                -- Transparent background, doesn't always work
  -- hl('Comment', 'none', { bg = 'GREEN' })              -- Keep foreground as parent
  -- hl('Comment', 'none', { fg = 'RED', bg = 'GREEN' })  -- Pass everything in last arg
  hl = function (groupName, colorName, options)
    -- Default options
    if not options then options = {} end
    options = F.clone(options) -- Prevent subtables to be modified when passed by reference

    -- Convert colors from short names
    if options.fg and options.fg ~= 'none' then options.fg = O.colors.env[options.fg] end
    if options.bg and options.bg ~= 'none' then options.bg = O.colors.env[options.bg] end

    local defaults = { 
      fg = O.colors.env[colorName],
      bg = "none",
      bold = false,
      italic = false,
    }
    local config = F.merge(defaults, options)

    -- make XXX and YYY standout
    if colorName == 'XXX' then
      config = { fg = O.colors.env.WHITE, bg = O.colors.env.CYAN, bold = true, }
    end
    if colorName == 'YYY' then
      config = { fg = O.colors.env.WHITE, bg = O.colors.env.PURPLE, }
    end

    vim.api.nvim_set_hl(0, groupName, config)
  end,

  -- color: Wrap a string in color highlight
  color = function (input, color)
    return '%#' .. color .. '#' .. input .. '%*'
  end,

  -- getData: Get info about a specific project, lazyloaded and cached
  getProjectData = function(projectKey)
    if not projectKey then
      return {}
    end

    -- Return cached version
    if O.projects[projectKey] then
      return O.projects[projectKey]
    end

    local function getAttribute(type)
      return F.env('PROJECT_' .. projectKey .. '_' .. type)
    end

    -- Stop if unknown project
    local projectPath = getAttribute('PATH')
    if not projectPath then
      return false
    end

    -- Get relevant project data
    local projectData = {
      name = projectKey:lower(),
      path = vim.fn.expand(projectPath), -- Convert ~ to full path
      icon = getAttribute('ICON'),
      bg = getAttribute('BACKGROUND_NAME'),
      fg = getAttribute('FOREGROUND_NAME'),
      hideNameInPrompt = getAttribute('HIDE_NAME_IN_PROMPT')
    }
    O.projects[projectKey] = projectData;

    return projectData
  end,

  -- getHighlightGroups: Return table of all highlight groups under cursor
  getHighlightGroups = function()
    local bufferId = F.bufferId()
    local position = F.position()

    -- Get groups defined by Treesitter
    local function getTreesitterCaptures(line, column)
      local treesitter = require('vim.treesitter')

      line = line - 1

      if F.isInsertMode() then
        column = column - 1
      end

      local allCaptures = treesitter.get_captures_at_pos(bufferId, line, column)
      return F.map(allCaptures, 'capture')
    end

    -- Get groups defined by syntax
    local function getSyntaxCaptures(line, column)
      if not F.isInsertMode() then
        column = column + 1
      end

      local ret = {}
      for _, synId in ipairs(vim.fn.synstack(line, column)) do
        synId = vim.fn.synIDtrans(synId)
        local synName = vim.fn.synIDattr(synId, 'name')
        F.append(ret, synName)
      end

      return ret
    end


    local treesitterCaptures = getTreesitterCaptures(position.line, position.column)
    local syntaxCaptures = getSyntaxCaptures(position.line, position.column)
    return F.concat(treesitterCaptures, syntaxCaptures)
  end,


  -- setGuicursor: Set the cursor shape and highlight for a specific mode
  setGuicursor = function(mode, type, highlight)
    -- First, remove any cursor set for this mode
    for _, value in ipairs(vim.opt.guicursor:get()) do
      local thisMode = F.split(value, ':')[1]
      if thisMode == mode then
        vim.opt.guicursor:remove(value)
      end
    end

    -- Add the new cursor
    vim.opt.guicursor:append(mode .. ':' .. type .. '-' .. highlight)
  end
}


--
--
