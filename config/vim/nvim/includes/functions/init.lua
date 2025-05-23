
-- append: Add an item to a table
function append(container, item)
  table.insert(container, item)
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
    fg = getAttribute('FOREGROUND_NAME')
  }
  vim.g.__projects[projectKey] = projectData;

  return projectData
end



require('oroshi/functions/autocmd')
require('oroshi/functions/highlight')
require('oroshi/functions/map')
