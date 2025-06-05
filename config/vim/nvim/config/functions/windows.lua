return {
  -- windowId: Returns current window id
  windowId = function()
    return vim.api.nvim_get_current_win()
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
