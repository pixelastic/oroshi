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
  -- openTab: Open a file in a new tab
  openTab = function(filepath, userOptions)
    if not filepath then
      return nil
    end

    -- Options
    local defaults = { focus = true }
    local options = F.merge(defaults, userOptions)

    -- Open new tab
    local oldTabId = F.tabId()
    vim.cmd("tab drop " .. F.fileEscape(filepath))
    local newTabId = F.tabId()

    -- By default it will focus on the newly opened tab
    if not options.focus then
      F.focusTab(oldTabId)
    end

    return newTabId
  end,
  -- closeTab: Close a specific tab or current tab
  closeTab = function(tabId)
    -- Attempt to save buffer before closing
    F.saveBuffer()

    -- If last tab, we instead close vim
    if F.tabCount() == 1 then
      vim.cmd("qall!")
      return
    end

    if tabId then
      vim.cmd(tabId .. "tabclose")
    else
      vim.cmd("tabclose")
    end
  end,
  -- focusTab: Focus a specific tab
  focusTab = function(tabId)
    vim.cmd("tabnext " .. tabId)
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
