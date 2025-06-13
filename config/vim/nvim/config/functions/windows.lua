return {
  -- windowId: Returns current window id
  windowId = function()
    return vim.api.nvim_get_current_win()
  end,
  -- windowWidth: Returns the width of the current window
  windowWidth = function()
    return vim.api.nvim_win_get_width(0)
  end,
  -- windowHeight: Returns the height of the current window
  windowHeight = function()
    return vim.api.nvim_win_get_height(0)
  end,
  -- focusWindow: Focus a specific window
  focusWindow = function(windowId)
    vim.api.nvim_set_current_win(windowId)
  end,
  -- closeWindow: Close a specific window
  closeWindow = function(windowId)
    local forceEvenIfUnsavedChanges = true
    vim.api.nvim_win_close(windowId, forceEvenIfUnsavedChanges)
  end,
}
