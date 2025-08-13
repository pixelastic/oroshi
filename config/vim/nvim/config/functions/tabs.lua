return {
  -- createTab: Create a new tab page
  createTab = function()
    vim.cmd("tabnew")
    return F.tabId()
  end,
  -- closeTab: Close a specific tab or current tab
  closeTab = function(tabId)
    if tabId then
      vim.cmd(tabId .. "tabclose")
    else
      vim.cmd("tabclose")
    end
  end,
  -- tabId: Returns the current tabId
  tabId = function()
    return vim.api.nvim_get_current_tabpage()
  end,
  -- tabCount: -- Returns the number of open tabs
  tabCount = function()
    return #vim.api.nvim_list_tabpages()
  end,
  -- tabSplits: Returns all splits in a specific tab
  tabSplits = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local allSplits = vim.api.nvim_tabpage_list_wins(tabId)
    return F.filter(allSplits, function(splitId)
      return F.isSplitValid(splitId)
    end)
  end,
  -- tabBuffers: Returns all buffers in a specific tab
  tabBuffers = function(tabId)
    -- Default to current tab
    if not tabId then
      tabId = F.tabId()
    end

    local buffers = {}
    F.each(F.tabSplits(tabId), function(splitId)
      F.append(buffers, F.getSplitBuffer(splitId))
    end)

    return buffers
  end,
}
