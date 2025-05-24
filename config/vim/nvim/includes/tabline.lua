vim.opt.tabpagemax = 1000 -- Do not limit max number of tabs open
vim.opt.showtabline = 1 -- Only show tabs if more than one
vim.opt.tabline = '%!v:lua.oroshiTabline()' -- Use custom function

function oroshiTabline()
  local tabline = {}

  -- We get all tabs that fit in the display
  local tabs = vim.g.tabline.displayedTabs(allTabs)

  -- Display them
  for i, tab in ipairs(tabs) do
    local nextTab = tabs[i + 1]
    vim.g.tabline.display(tabline, tab, nextTab)
  end

  return table.concat(tabline, '')
end


vim.g.tabline = {
  -- Get metadata for a given tab
  getTab = function(index)
    -- isCurrent
    local currentTab = vim.fn.tabpagenr()
    local isCurrent = currentTab == index
    -- filepath
    local bufferId = vim.fn.tabpagebuflist(index)[1]
    local fullPath = vim.fn.expand('#' .. bufferId .. ':p')

    -- content
    local basename = vim.fn.fnamemodify(fullPath, ':t')
    local content = ' ' .. basename .. ' '
    -- width
    local separatorWidth = 1
    local width = vim.fn.strdisplaywidth(content) + separatorWidth
    -- hl
    local hl = { fg = 'WHITE', bg = 'GRAY_8' }
    -- separator
    if isCurrent then
      hl = { fg = 'YELLOW', bg = 'BLACK' }
    end

    return {
      index = index,
      isCurrent = isCurrent,
      filepath = filepath,
      content = content,
      width = width,
      hl = hl
    }
  end,

  -- Add the tab to the displayed tabline
  display = function(tabline, tab, nextTab)
    if not nextTab then nextTab = { hl = { bg = 'GRAY_8' } } end

    -- Start of click area
    append(tabline, '%' .. (tab.index) .. 'T')

    -- Content
    local displayedContent = tab.content
    local content = vim.g.tabline.colorize(displayedContent, tab.index, tab.hl)
    append(tabline, content)

    -- Separator
    local separatorString = ''
    local separatorHightlight = {
      bg = vim.g.tabline.defaultBg,
      fg = vim.g.tabline.defaultFg,
    }
    -- Update colors if current or next is the current one
    if tab.isCurrent or nextTab.isCurrent then
      separatorString = ''
      separatorHightlight = {
        bg = tab.hl.bg,
        fg = nextTab.hl.bg
      }
    end
    local separator = vim.g.tabline.colorize(separatorString, tab.index .. 'Separator', separatorHightlight)
    append(tabline, separator)

    -- End of click area
    append(tabline, '%T') 
  end,

  -- Returns only the tabs to display
  displayedTabs = function()
    -- We get all the tabs
    local allTabs = vim.g.tabline.allTabs()

    --  We need to add tabs, one by one, around the current one, until
    -- we run out of space
    local availableWidth = vim.o.columns;
    local displayedTabs = {}

    -- Add current tab, for sure
    local currentTab = vim.g.tabline.getCurrentTab(allTabs)
    append(displayedTabs, currentTab)
    local usedWidth = currentTab.width

    -- Get all tabs, by order of importance (proximity with current tab)
    local tabQueue = vim.g.tabline.buildTabQueue(allTabs, currentTab)

    -- Add them to the list of displayed tabs until we run out of space
    for i, item in ipairs(tabQueue) do
      local direction = item.direction
      local tab = item.tab

      -- Stop if no enough space to add this tab
      if usedWidth + tab.width > availableWidth then
        return displayedTabs
      end

      -- Add the tab, either before or after
      if direction == 'before' then
        prepend(displayedTabs, tab)
      else
        append(displayedTabs, tab)
      end

      -- Increase consumed width
      usedWidth = usedWidth + tab.width
    end


    return displayedTabs
  end,

  -- Build a list of all tabs that should be added in addition to the current
  -- one, in order of preference, and with their position (before or after)
  buildTabQueue = function(allTabs, currentTab)
    -- Build the list of tabs to try, one before, one after, etc
    local totalTabCount = #allTabs
    local offset = 1
    local tabQueue = {}
    for i = 1, totalTabCount - 1 do
      local direction = i % 2 == 0 and 'after' or 'before'

      -- Grab the tab before and after
      local indexBefore = currentTab.index - offset
      local indexAfter = currentTab.index + offset

      -- Change direction if out of bounds
      if direction == 'before' and indexBefore <= 0 then
        direction = 'after'
      end
      if direction == 'after' and indexAfter > totalTabCount then
        direction = 'before'
        indexBefore = indexBefore - 1
      end

      -- Add the tab where needed
      if direction == 'before' then
        append(tabQueue, { direction = 'before', tab = allTabs[indexBefore] })
      else
        append(tabQueue, { direction = 'after', tab = allTabs[indexAfter] })
        offset = offset + 1
      end
    end

    return tabQueue
  end,

  -- Get metadata from all opened tabs
  allTabs = function()
    local tabs = {}
    local count = vim.fn.tabpagenr('$')
    for i = 1, count do
      append(tabs, vim.g.tabline.getTab(i))
    end

    return tabs
  end,

  -- Find the current tab
  getCurrentTab = function(tabs)
    for _, tab in ipairs(tabs) do
      if tab.isCurrent then
        return tab
      end
    end
    return false
  end,

  -- Color a string in a given highlight
  colorize = function(content, identifier, highlight)
    -- Create a unique highlight group and define its colors
    local highlightName = 'TablineSlot' .. identifier
    hl(highlightName, 'none', highlight)
    -- Wrap the content in this group
    return color(content, highlightName)
  end,

  -- Should be the same as TabLineFill
  defaultBg = 'GRAY_8',
  defaultFg = 'GRAY_4',
}



