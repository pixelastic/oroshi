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
  -- allWindows: Returns all windowIds
  allWindows = function()
    return vim.api.nvim_list_wins()
  end,
  -- isWindowValid: Check if a window handle is valid.
  -- Note: windows can get deleted, and thus operations on them will fail
  isWindowValid = function(windowId)
    return vim.api.nvim_win_is_valid(windowId)
  end,
  -- getWindowBuffer: Returns the bufferId of the specified window
  getWindowBuffer = function(windowId)
    return vim.api.nvim_win_get_buf(windowId)
  end,
  -- closeWindow: Close a window
  closeWindow = function(input)
    -- If a callback is passed, it is called with each bufferId currently
    -- displayed in a window. If the callback returns true, the window is
    -- closed.
    if F.isFunction(input) then
      local callback = input
      local allWindows = F.allWindows()
      for _, windowId in ipairs(allWindows) do
        -- Skip invalid windows
        if not F.isWindowValid(windowId) then
          goto continue
        end

        -- Close if callback returns true
        local bufferId = F.getWindowBuffer(windowId)
        if callback(bufferId) then
          F.closeWindow(windowId)
        end

        ::continue::
      end
      return
    end

    -- If the windowId is passed, the specified window is closed
    local windowId = input
    local forceEvenIfUnsavedChanges = true
    vim.api.nvim_win_close(windowId, forceEvenIfUnsavedChanges)
  end,
}
