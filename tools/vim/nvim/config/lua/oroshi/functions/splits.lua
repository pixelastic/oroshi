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
  -- createFloatingSplit: Create a floating window split
  -- options: width, height, top, left
  createFloatingSplit = function(content, userOptions)
    userOptions = userOptions or {}

    -- Create the buffer
    local bufferId = F.createBuffer()
    F.updateBuffer(content, bufferId)
    -- Set buffer options
    if userOptions.options then
      F.each(userOptions.options, function(value, key)
        F.updateBufferOption(key, value, bufferId)
      end)
    end

    -- Position the window
    local maxWidth = vim.o.columns
    local windowWidth = userOptions.width or math.floor(maxWidth * 0.7)
    local windowLeft = userOptions.left or (maxWidth - windowWidth) / 2

    local maxHeight = vim.o.lines
    local windowHeight = userOptions.height or math.floor(maxHeight * 0.5)
    local windowTop = userOptions.top or (maxHeight - windowHeight) / 2
    local options = {
      relative = "editor",
      style = "minimal",
      border = "rounded",
      width = windowWidth,
      height = windowHeight,
      col = windowLeft,
      row = windowTop,
    }

    -- Display it
    return vim.api.nvim_open_win(bufferId, true, options)
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
