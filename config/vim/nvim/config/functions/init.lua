__ = {
  vars = {},

  -- Table handling {{{
  -- append: Add an element at the end of a table
  append = function(container, item)
    table.insert(container, item)
  end,
  -- prepend: Add an element at the beginning of a table
  prepend = function(container, item)
    table.insert(container, 1, item)
  end,
  -- }}}

  -- Debug {{{
  debug = function(input)
    local inputType = type(input)
    local displayedInput = input
    if inputType == 'table' then
      displayedInput = vim.inspect(input)
    end

    vim.notify(displayedInput, vim.log.levels.INFO)
  end,
  -- }}}

  -- Hacks {{{
  -- ensureVisualSelection
  hack_ensureVisualSelection = function()
    -- '< and '> marks are only updated when leaving visual mode
    -- So if we need to use them in a lua method, we first need to leave and
    -- quickly come back in visual mode to be able to use '< and '> in the
    -- mapping
    vim.api.nvim_command('normal ') -- <Esc> to leave visual mode
    vim.cmd('normal gv') -- Reselecting previous selection
  end,
  -- }}}
}

-- debug: Display a variable in a floating window
function d(input)
  vim.schedule(function()
    vim.notify(vim.inspect(input))
  end)
end


-- getColors: Define vim.g.colors once and for all
local function getColors()
  local colors = {}

  local env_COLORS_INDEX = os.getenv('COLORS_INDEX')
  local items = vim.split(env_COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = string.gsub(item, 'ALIAS_', '')
    local value = os.getenv('COLOR_' .. item .. '_HEXA')
    colors[key] = value
  end
  return colors
end
vim.g.colors = getColors()

-- getProjectData: Get info about a specific project, lazyloaded and cached
vim.g.__projects = {}
function getProject(projectKey)
  -- Return cached version
  if vim.g.__projects[projectKey] then
    return vim.g.__projects[projectKey]
  end

  function getAttribute(type)
    return os.getenv('PROJECT_' .. projectKey .. '_' .. type)
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
  vim.g.__projects[projectKey] = projectData;

  return projectData
end

frequire('oroshi/functions/autocmd')
frequire('oroshi/functions/highlight')
frequire('oroshi/functions/map')
