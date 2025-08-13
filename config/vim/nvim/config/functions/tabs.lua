return {
  -- tabId: Returns the current tabId
  tabId = function()
    return vim.api.nvim_get_current_tabpage()
  end,
  -- tabCount: -- Returns the number of open tabs
  tabCount = function()
    return #vim.api.nvim_list_tabpages()
  end,
  -- getTabSplits: Returns all splits in a specific tab
  getTabSplits = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local allSplits = vim.api.nvim_tabpage_list_wins(tabId)
    return F.filter(allSplits, function(splitId)
      return F.isSplitValid(splitId)
    end)
  end,
  -- getTabBuffers: Returns all buffers in a specific tab
  getTabBuffers = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local buffers = {}
    F.each(F.getTabSplits(tabId), function(splitId)
      F.append(buffers, F.getSplitBuffer(splitId))
    end)

    return buffers
  end,
}
