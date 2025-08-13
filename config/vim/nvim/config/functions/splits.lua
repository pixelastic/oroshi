return {
  -- createSplit: Create a new split (horizontal by default)
  createSplit = function(vertical)
    if vertical then
      vim.cmd("vsplit")
    else
      vim.cmd("split")
    end
    return F.splitId()
  end,
  -- splitId: Returns current split id
  splitId = function()
    return vim.api.nvim_get_current_win()
  end,
  -- splitWidth: Returns the width of the current split
  splitWidth = function()
    return vim.api.nvim_win_get_width(0)
  end,
  -- splitHeight: Returns the height of the current split
  splitHeight = function()
    return vim.api.nvim_win_get_height(0)
  end,
  -- focusSplit: Focus a specific split
  focusSplit = function(splitId)
    vim.api.nvim_set_current_win(splitId)
  end,
  -- allSplits: Returns all splitIds
  allSplits = function()
    return vim.api.nvim_list_wins()
  end,
  -- splitExists: Check if a split exists.
  -- Note: splits can get deleted, and thus operations on them will fail
  splitExists = function(splitId)
    return vim.api.nvim_win_is_valid(splitId)
  end,
  -- getSplitBuffer: Returns the bufferId of the specified split
  getSplitBuffer = function(splitId)
    return vim.api.nvim_win_get_buf(splitId)
  end,
  -- closeSplit: Close a split
  closeSplit = function(input)
    -- If a callback is passed, it is called with each bufferId currently
    -- displayed in a split. If the callback returns true, the split is
    -- closed.
    if F.isFunction(input) then
      local callback = input
      local allSplits = F.allSplits()
      for _, splitId in ipairs(allSplits) do
        -- Skip invalid splits
        if not F.splitExists(splitId) then
          goto continue
        end

        -- Close if callback returns true
        local bufferId = F.getSplitBuffer(splitId)
        if callback(bufferId) then
          F.closeSplit(splitId)
        end

        ::continue::
      end
      return
    end

    -- If the splitId is passed, the specified split is closed
    local splitId = input
    local forceEvenIfUnsavedChanges = true
    vim.api.nvim_win_close(splitId, forceEvenIfUnsavedChanges)
  end,
}
