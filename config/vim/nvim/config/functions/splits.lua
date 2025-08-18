return {
  -- splitId: Returns current split id
  splitId = function()
    return vim.api.nvim_get_current_win()
  end,
  -- splits: Returns all splitIds (defaults to current tab)
  splits = function(tabId)
    tabId = tabId or F.tabId()
    return vim.api.nvim_tabpage_list_wins(tabId)
  end,
  -- splitExists: Check if a split exists.
  splitExists = function(splitId)
    return vim.api.nvim_win_is_valid(splitId)
  end,
  -- createSplit: Create a new split
  createSplit = function()
    vim.cmd("split")
    return F.splitId()
  end,
  -- closeSplit: Close a split (defaults to current split)
  closeSplit = function(splitId)
    splitId = splitId or F.splitId()

    -- Try to close the window
    local isClosed, errorMessage = pcall(function()
      local forceEvenIfUnsavedChanges = true
      vim.api.nvim_win_close(splitId, forceEvenIfUnsavedChanges)
    end)

    -- If this is the last window opened in vim, the above nvim_win_close will fail with
    -- "Vim:E444: Cannot close last window". In that case, we close the whole
    -- tab
    if not isClosed and F.includes(errorMessage, "Vim:E444") then
      F.closeTab()
    end
  end,
  -- splitCount: Returns the number of opened splits (defaults to current tab)
  splitCount = function(tabId)
    return #F.splits(tabId)
  end,
  -- forEachSplit: Apply a callback on each split (defaults to current tab)
  forEachSplit = function(callback, tabId)
    F.each(F.splits(tabId), function(splitId)
      callback(splitId)
    end)
  end,

  -- globalSplits: Returns all splitIds from all tabs
  globalSplits = function()
    return vim.api.nvim_list_wins()
  end,

  -- focusSplit: Focus a specific split
  focusSplit = function(splitId)
    vim.api.nvim_set_current_win(splitId)
  end,
  -- dimensions: Returns the split dimensions (defaults to current split)
  dimensions = function(splitId)
    return {
      width = F.width(splitId),
      height = F.height(splitId),
    }
  end,
  -- width: Returns the width of a split (defaults to current split)
  width = function(splitId)
    splitId = splitId or F.splitId()
    return vim.api.nvim_win_get_width(splitId)
  end,
  -- height: Returns the height of a split (defaults to current split)
  height = function(splitId)
    splitId = splitId or F.splitId()
    return vim.api.nvim_win_get_height(splitId)
  end,
}
