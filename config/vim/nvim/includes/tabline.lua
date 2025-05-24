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
  -- Should be the same as TabLineFill
  defaultBg = 'GRAY_8',
  defaultFg = 'GRAY_4',
  -- Get metadata from all opened tabs
  allTabs = function()
    local tabs = {}
    local count = vim.fn.tabpagenr('$')
    for i = 1, count do
      append(tabs, vim.g.tabline.getTab(i))
    end

    return tabs
  end,
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
      hl = { fg = 'ORANGE', bg = 'BLACK' }
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
  -- Returns only the tabs to display
  displayedTabs = function()
    -- We get all the tabs
    local allTabs = vim.g.tabline.allTabs()

    -- Happy path: we have enough space to display everything
    local availableWidth = vim.o.columns;
    local maxTabWidth = 0
    for _, tab in ipairs(allTabs) do
      maxTabWidth = maxTabWidth + tab.width
    end
    if availableWidth >= maxTabWidth then
      return allTabs
    end

    -- Edge case: We need to add tabs, one by one, around the current one, until
    -- we run out of space
    local displayedTabs = {}

    -- We first add the current tab
    local currentTab = vim.g.tabline.getCurrentTab(allTabs)
    append(displayedTabs, currentTab)

    return displayedTabs



    -- Edge case, we need to specific which tabs to keep
    -- On commence par ajouter le tab actif
    -- S'il reste le la place, on ajouter le tab d'avant
    -- s'il reste de la place, on ajoute le tab d'apres
    -- puis avant, après, avant, apres, jusqu'à ce qu'il n'y ai plus de place

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
}



