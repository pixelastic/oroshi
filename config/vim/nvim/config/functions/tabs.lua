return {
  -- tabId: Returns the current tabId
  tabId = function()
    return vim.api.nvim_get_current_tabpage()
  end,
  -- tabCount: -- Returns the number of open tabs
  tabCount = function()
    return #vim.api.nvim_list_tabpages()
  end,
  -- getTabWindows: Returns all windows in a specific tab
  getTabWindows = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local allWindows = vim.api.nvim_tabpage_list_wins(tabId)
    return F.filter(allWindows, function(windowId)
      return F.isWindowValid(windowId)
    end)
  end,
  -- getTabBuffers: Returns all buffers in a specific tab
  getTabBuffers = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local buffers = {}
    F.each(F.getTabWindows(tabId), function(windowId)
      F.append(buffers, F.getWindowBuffer(windowId))
    end)

    return buffers
  end,
}
