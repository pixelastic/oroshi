vim.opt.tabpagemax = 1000 -- Do not limit max number of tabs open
vim.opt.showtabline = 1 -- Only show tabs if more than one
vim.opt.tabline = '%!v:lua.__.tabline.main()' -- Use custom function

__.tabline = {
  -- main: Main entrypoint for vim.opt.tabline
  main = function()
    local tabline = {}

    -- We get all tabs that fit in the display
    local tabs = __.tabline.displayedTabs(allTabs)

    -- Display them
    for i, tab in ipairs(tabs) do
      local nextTab = tabs[i + 1]
      __.tabline.display(tabline, tab, nextTab)
    end

    return table.concat(tabline, '')
  end,

  -- Get metadata for a given tab
  getTab = function(index)
    -- isCurrent
    local currentTab = vim.fn.tabpagenr()
    local isCurrent = currentTab == index
    -- filepath
    local fullPath = __.tabline.getFullpath(index)
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
    __.append(tabline, '%' .. (tab.index) .. 'T')


    -- Content
    local displayedContent = tab.content
    local content = __.tabline.colorize(displayedContent, tab.index, tab.hl)
    __.append(tabline, content)

    -- Separator
    local separatorString = ''
    local separatorHightlight = __.vars.tabline.hl;
    -- Update colors if current or next is the current one
    if tab.isCurrent or nextTab.isCurrent then
      separatorString = ''
      separatorHightlight = {
        bg = tab.hl.bg,
        fg = nextTab.hl.bg
      }
    end
    local separator = __.tabline.colorize(separatorString, tab.index .. 'Separator', separatorHightlight)
    __.append(tabline, separator)

    -- End of click area
    __.append(tabline, '%T') 
  end,

  -- Returns only the tabs to display
  displayedTabs = function()
    -- We get all the tabs
    local allTabs = __.tabline.allTabs()

    --  We need to add tabs, one by one, around the current one, until
    -- we run out of space
    local availableWidth = vim.o.columns;
    local displayedTabs = {}

    -- Add current tab, for sure
    local currentTab = __.tabline.getCurrentTab(allTabs)
    __.append(displayedTabs, currentTab)
    local usedWidth = currentTab.width

    -- Get all tabs, by order of importance (proximity with current tab)
    local tabQueue = __.tabline.buildTabQueue(allTabs, currentTab)

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
        __.prepend(displayedTabs, tab)
      else
        __.append(displayedTabs, tab)
      end

      -- Increase consumed width
      usedWidth = usedWidth + tab.width
    end


    return displayedTabs
  end,

  -- Build a list of all tabs that should be added in addition to the current
  -- one, in order of preference, and with their position (before or after)
  -- TODO: There is an off by one error. I should remove elements from allTabs
  -- as I add them to tabQueue, this would make it more efficient. But I want to
  -- use a AI plugin to find how to do that
  buildTabQueue = function(allTabs, currentTab)
    -- Build the list of tabs to try, one before, one after, etc
    local totalTabCount = #allTabs
    local offset = 1
    local tabQueue = {}
    for i = 1, totalTabCount - 1 do
      local isOdd = i % 2 == 1
      local direction = isOdd and 'before' or 'after'

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
        __.append(tabQueue, { direction = 'before', tab = allTabs[indexBefore] })
      else
        __.append(tabQueue, { direction = 'after', tab = allTabs[indexAfter] })
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
      __.append(tabs, __.tabline.getTab(i))
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

  -- getFullpath: Return the path to the file being edited in a given tab
  getFullpath = function(tabIndex)
    local bufferId = vim.fn.tabpagebuflist(tabIndex)[1]

    -- If the first buffer is NvimTree, grab the next one
    local filetype = vim.bo[bufferId].filetype
    if filetype == 'NvimTree' then
      bufferId = vim.fn.tabpagebuflist(tabIndex)[2]
    end

    local fullPath = vim.fn.expand('#' .. bufferId .. ':p')
    return fullPath
  end,

  -- Color a string in a given highlight
  colorize = function(content, identifier, highlight)
    -- Create a unique highlight group and define its colors
    local highlightName = 'TablineSlot' .. identifier
    hl(highlightName, 'none', highlight)
    -- Wrap the content in this group
    return color(content, highlightName)
  end,
}
