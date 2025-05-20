vim.opt.tabpagemax = 1000 -- Do not limit max number of tabs open
vim.opt.showtabline = 1 -- Only show tabs if more than one
vim.opt.tabline = '%!v:lua.oroshiTabline()' -- Use custom function

function oroshiTabline()
  local tabline = {}
  local currentTab = vim.fn.tabpagenr()
  local totalTabs = vim.fn.tabpagenr('$')

  -- Define the label of a given tab
  local function label(tabIndex)
    local bufferId = vim.fn.tabpagebuflist(tabIndex)[1]
    local fullPath = vim.fn.expand('#' .. bufferId .. ':p')
    local basename = vim.fn.fnamemodify(fullPath, ':t')
    local isCurrentTab = (tabIndex == currentTab)

    local label = {}

    -- Current tab
    if isCurrentTab then
      append(label, color('', 'TabLineSelSeparator'))
      append(label, color(' '..basename..' ', 'TabLineSel'))
      append(label, color('', 'TabLineSelSeparator'))
      return table.concat(label, '')
    end

    -- Regular tab
    append(label, color(' ' .. basename .. ' ', 'TabLine'))
    return table.concat(label, '')
  end


  -- Add all labels to the tabline
  for tabIndex = 1, totalTabs do
    local tabLabel = label(tabIndex)

    append(tabline, '%' .. (tabIndex) .. 'T') -- Start of click area
    append(tabline, tabLabel)
    append(tabline, '%T') -- End of click area
  end

  return table.concat(tabline, '')
end
