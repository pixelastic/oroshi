return {
  -- tabId: Returns the current tabId
  tabId = function()
    return vim.api.nvim_get_current_tabpage()
  end,
  -- tabs: Returns all open tabs
  tabs = function()
    return vim.api.nvim_list_tabpages()
  end,
  -- tabExists: Check if a tab exists
  tabExists = function(tabId)
    return vim.api.nvim_tabpage_is_valid(tabId)
  end,
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
  -- tabCount: Returns the number of open tabs
  tabCount = function()
    return #F.tabs()
  end,
  -- forEachTab: Apply a callback on each tab
  forEachTab = function(callback)
    F.each(F.tabs(), function(tabId)
      callback(tabId)
    end)
  end,
}
