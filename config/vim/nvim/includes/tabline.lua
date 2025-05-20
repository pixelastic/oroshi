vim.opt.tabpagemax = 1000 -- Do not limit max number of tabs open
vim.opt.showtabline = 1 -- Only show tabs if more than one
vim.opt.tabline = '%!v:lua.oroshiTabline()' -- Use custom function

function oroshiTabline()
  local tabline = {}
  local currentTab = vim.fn.tabpagenr()
  local totalTabs = vim.fn.tabpagenr('$')

  -- Define how a given tab should be displayed
  local function tab(tabIndex)
    local bufferId = vim.fn.tabpagebuflist(tabIndex)[1]
    local fullPath = vim.fn.expand('#' .. bufferId .. ':p')
    local basename = vim.fn.fnamemodify(fullPath, ':t')
    local isCurrentTab = (tabIndex == currentTab)
    local isModified = vim.bo[bufferId].modified

    -- Label: How is the tab named
    local label = {}
    append(label, ' ')
    append(label, basename)
    if isModified then append(label, ' ') end
    append(label, ' ')
    local labelString = table.concat(label, '')

    -- Tab: How is the tab presented
    local tab = {}
    if isCurrentTab then 
      append(tab, color('', 'TabLineSelSeparator'))
      append(tab, color(labelString, 'TabLineSel'))
      append(tab, color('', 'TabLineSelSeparator'))
    else
      append(tab, color(labelString, 'TabLine'))
    end

    return table.concat(tab, '')
  end


  -- Add all labels to the tabline
  for tabIndex = 1, totalTabs do
    local tab = tab(tabIndex)

    append(tabline, '%' .. (tabIndex) .. 'T') -- Start of click area
    append(tabline, tab)
    append(tabline, '%T') -- End of click area
  end

  return table.concat(tabline, '')
end
