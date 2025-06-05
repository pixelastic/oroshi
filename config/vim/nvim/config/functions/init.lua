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

  -- Types {{{
  isTable = function(input)
    return type(input) == 'table'
  end,
  -- }}}

  -- File handling {{{
  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand('%') == ''
  end,
  -- isInsertMode: Check if we are in Insert mode
  isInsertMode = function()
    return vim.api.nvim_get_mode().mode == 'i'
  end,
  -- normalMode: Switch to normal mode
  normalMode = function()
    vim.api.nvim_command('normal ') -- Press <Esc>
  end,
  -- insertMode: Switch to insert mode
  insertMode = function()
    vim.cmd.startinsert()
  end,
  -- getBufferId: Returns current buffer id
  getBufferId = function()
    return vim.api.nvim_get_current_buf()
  end,
  -- getWindowId: Returns current window id
  getWindowId = function()
    return vim.api.nvim_get_current_win()
  end,
  -- focusWindow: Focus a specific window
  focusWindow = function(windowId)
    vim.api.nvim_set_current_win(windowId)
  end,
  -- closeWindow: Close a specific window
  closeWindow = function(windowId)
    local forceEvenIfUnsavedChanges = true
    vim.api.nvim_win_close(windowId, forceEvenIfUnsavedChanges)
  end,
  -- getCursor: Returns cursor position (row, col)
  getCursor = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return {
      row = row,
      col = col
    }
  end,
  -- currentLine: get/set the current line
  currentLine = function(input)
    if not input then
      return vim.api.nvim_get_current_line();
    end

    vim.api.nvim_set_current_line(input)
  end,
  -- }}}

  -- Misc {{{
  -- debug: Display a variable
  debug = function(input)
    local displayedInput = input
    if __.isTable(input) then
      displayedInput = vim.inspect(input)
    end

    vim.schedule(function()
      local success, error = pcall(function()
        vim.notify(displayedInput, vim.log.levels.INFO)
      end)
      if error then
        vim.print(displayedInput)
      end
    end)
  end,
  -- env: Get an environment variable
  env = function(name)
    return os.getenv(name)
  end,
  -- }}}

  -- Hacks {{{
  -- ensureVisualSelection
  hack_ensureVisualSelection = function()
    -- '< and '> marks are only updated when leaving visual mode
    -- So if we need to use them in a lua method, we first need to leave and
    -- quickly come back in visual mode to be able to use '< and '> in the
    -- mapping
    __.normalMode()      -- <Esc> to leave visual mode
    vim.cmd('normal gv') -- Reselecting previous selection
  end,
  -- }}}
}

frequire('oroshi/functions/_')
frequire('oroshi/functions/autocmd')
frequire('oroshi/functions/highlight')
frequire('oroshi/functions/map')


-- getColors: Define vim.g.colors once and for all
local function getColors()
  local colors = {}

  local env_COLORS_INDEX = __.env('COLORS_INDEX')
  local items = vim.split(env_COLORS_INDEX, " ", { trimempty = true })
  for _, item in ipairs(items) do
    local key = __._.replace(item, 'ALIAS_', '')
    local value = __.env('COLOR_' .. item .. '_HEXA')
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
    return __.env('PROJECT_' .. projectKey .. '_' .. type)
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
