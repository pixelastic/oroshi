-- Private functions
local hlFiletype
local getHighlightsUnderCursor

local M = {}

-- hl: Define colors for a specific highlight group
-- Usage:
-- hl('Comment', 'RED')                                 -- Foreground color only
-- hl('Comment', 'RED', { bg = 'GREEN' })               -- Also background
-- hl('Comment', 'RED', { bold = true })                -- Also bold
-- hl('Comment', 'RED', { blend = 100 })                -- Transparent background, doesn't always work
-- hl('Comment', 'none', { bg = 'GREEN' })              -- Keep foreground as parent
-- hl('Comment', 'none', { fg = 'RED', bg = 'GREEN' })  -- Pass everything in last arg
-- hl('htmlTag', 'ORANGE', { filetype = 'vue' })        -- Only apply to vue files
-- hl('htmlTag', 'GREEN', { temporary = true })         -- Means this highlight is temporary and will be reverted by F2
M.hl = function(groupName, colorName, options)
  -- Default options
  if not options then
    options = {}
  end
  options = F.clone(options) -- Prevent subtables to be modified when passed by reference

  -- Handle filetype-specific highlights
  if options.filetype then
    hlFiletype(groupName, colorName, options)
    return
  end

  local isTemporary = options.temporary
  options.temporary = nil

  -- Convert colors from short names
  if options.fg and options.fg ~= "none" then
    options.fg = O.colors.env[options.fg]
  end
  if options.bg and options.bg ~= "none" then
    options.bg = O.colors.env[options.bg]
  end
  if options.sp and options.sp ~= "none" then
    options.sp = O.colors.env[options.sp]
  end

  local defaults = {
    fg = O.colors.env[colorName],
    bg = "none",
    bold = false,
    italic = false,
  }
  local config = F.merge(defaults, options)

  -- make XXX and YYY standout
  if colorName == "XXX" then
    config = { fg = O.colors.env.WHITE, bg = O.colors.env.CYAN, bold = true }
  end
  if colorName == "YYY" then
    config = { fg = O.colors.env.WHITE, bg = O.colors.env.PURPLE }
  end

  -- Save this highlight definition
  if not isTemporary then
    O.highlights[groupName] = {
      groupName = groupName,
      colorName = colorName,
      options = options,
    }
  end

  vim.api.nvim_set_hl(0, groupName, config)
end

-- initFiletypeSpecificHighlights: Setup filetype-specific highlight system
M.initFiletypeSpecificHighlights = function()
  -- Apply filetype-specific highlights on buffer enter
  F.autocmd("BufEnter", function()
    M.applyHighlightForFiletype(F.bufferOption("filetype"))
  end)

  -- Restore default highlights on buffer leave
  F.autocmd("BufLeave", function()
    M.restoreHighlightForFiletype(F.bufferOption("filetype"))
  end)
end

-- applyHighlightForFiletype: Apply highlights for a specific filetype
M.applyHighlightForFiletype = function(filetype)
  local highlights = F.get(O, "filetypeHighlights." .. filetype)
  if not highlights then
    return
  end

  F.each(highlights, function(hl)
    -- Set temporary so we do not override the default definition for this group
    local options = F.clone(hl.options)
    options.temporary = true

    F.hl(hl.groupName, hl.colorName, options)
  end)
end

-- restoreHighlightForFiletype: Restore default highlights for a specific filetype
M.restoreHighlightForFiletype = function(filetype)
  local highlights = F.get(O, "filetypeHighlights." .. filetype)
  if not highlights then
    return
  end

  F.each(highlights, function(hl)
    local groupName = hl.groupName
    local defaultHl = O.highlights[hl.groupName]
    if not defaultHl then
      F.warn(groupName .. " has custom highlight in " .. filetype .. " but no default highlight")
      defaultHl = {
        colorName = "none",
        options = {},
      }
    end
    F.hl(groupName, defaultHl.colorName, defaultHl.options)
  end)
end

-- color: Wrap a string in color highlight
M.color = function(input, color)
  return "%#" .. color .. "#" .. input .. "%*"
end

-- getData: Get info about a specific project, lazyloaded and cached
M.getProjectData = function(projectKey)
  if not projectKey then
    return {
      name = "",
      path = "",
      icon = "",
      hl = {},
      hideNameInPrompt = false,
    }
  end

  -- Return cached version
  if O.projects[projectKey] then
    return O.projects[projectKey]
  end

  local function getAttribute(type)
    return F.env("PROJECT_" .. projectKey .. "_" .. type)
  end

  -- Stop if unknown project
  local projectPath = getAttribute("PATH")
  if not projectPath then
    return false
  end

  -- Get relevant project data
  local projectData = {
    name = projectKey:lower(),
    path = vim.fn.expand(projectPath), -- Convert ~ to full path
    icon = getAttribute("ICON"),
    hl = {
      bg = getAttribute("BACKGROUND_NAME"),
      fg = getAttribute("FOREGROUND_NAME"),
    },
    hideNameInPrompt = getAttribute("HIDE_NAME_IN_PROMPT"),
  }
  O.projects[projectKey] = projectData

  return projectData
end

-- setGuicursor: Set the cursor shape and highlight for a specific mode
M.setGuicursor = function(mode, type, highlight)
  -- First, remove any cursor set for this mode
  for _, value in ipairs(vim.opt.guicursor:get()) do
    local thisMode = F.split(value, ":")[1]
    if thisMode == mode then
      vim.opt.guicursor:remove(value)
    end
  end

  -- Add the new cursor
  vim.opt.guicursor:append(mode .. ":" .. type .. "-" .. highlight)
end

-- debugColors: Show all highlight groups under cursor
M.debugColors = function()
  -- Close the previously opened debugColors window.
  -- Otherwise it will get re-used, even if offscreen in another tab
  local closeExistingSplit = function()
    F.each(F.globalSplits(), function(splitId)
      -- Deleting the highlight debug split might also delete subsplits that
      -- we now need to skip
      if not F.splitExists(splitId) then
        return
      end

      -- Close the previous split used for that debugging
      local bufferId = F.bufferId(splitId)
      local bufferFiletype = F.bufferOption("filetype", bufferId)
      local lastLine = F.line(-1, bufferId)
      if bufferFiletype == "noice" and lastLine == "O_DEBUG_COLORS" then
        F.closeSplit(splitId)
      end
    end)
  end

  -- Find current highlights
  local highlights = getHighlightsUnderCursor()
  -- Stop if none found
  if #highlights == 0 then
    closeExistingSplit()
    F.warn("No highlights")
    return
  end

  -- Build the colored text to display
  local content = {}
  F.each(highlights, function(item)
    -- If the group is linked to itself, it means it's disabled
    -- if item.link == item.hl then
    --   F.append(content, { " // ", "Comment" })
    --   F.append(content, { item.hl, "Comment" })
    --   F.append(content, { " is disabled", "Comment" })
    --   F.append(content, { "\n", "Comment" })
    --   return
    -- end
    F.append(content, { "    ", item.hl })
    F.append(content, { item.hl, item.hl })
    F.append(content, { " linked to ", "Comment" })
    F.append(content, { item.link, item.link })
    F.append(content, { "\n", "Comment" })
  end)
  -- Add a invisible marker so we can filter it in noice routes
  F.append(content, { "\n\n\nO_DEBUG_COLORS", "EndOfBuffer" })

  -- Echo it using nvim_echo as this is the only way to display colors that I
  -- know
  -- This will actually be swallowed by noice, but added to the history
  vim.api.nvim_echo(content, true, {})

  -- Display the last element in history
  -- We need to wait a bit, to let noice process the echo
  F.defer(function()
    closeExistingSplit()
    require("noice").cmd("showDebugColors")
  end)
end

-- Private functions
-- hlFiletype: Handle filetype-specific highlights
function hlFiletype(groupName, colorName, options)
  local filetype = options.filetype
  options.filetype = nil

  -- Save highlights for this filetype
  if not O.filetypeHighlights[filetype] then
    O.filetypeHighlights[filetype] = {}
  end
  F.append(O.filetypeHighlights[filetype], {
    groupName = groupName,
    colorName = colorName,
    options = options,
  })
end

-- getHighlightsUnderCursor: Returns a collection of hl and link under cursor
function getHighlightsUnderCursor()
  local highlightData = vim.inspect_pos()
  local highlights = {}

  -- Syntax
  for _, item in ipairs(highlightData.syntax) do
    F.append(highlights, {
      hl = item.hl_group,
      link = item.hl_group_link or "",
    })
  end
  -- Treesitter
  for _, item in ipairs(highlightData.treesitter) do
    F.append(highlights, {
      hl = item.hl_group,
      link = item.hl_group_link or "",
    })
  end
  -- Extmarks
  for _, item in ipairs(highlightData.extmarks) do
    F.append(highlights, {
      hl = item.opts.hl_group,
      link = item.opts.hl_group_link,
    })
  end

  return highlights
end

return M
