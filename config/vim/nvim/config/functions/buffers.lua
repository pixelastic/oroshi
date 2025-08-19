return {
  -- bufferId: Returns current buffer id, or buffer of specified split
  bufferId = function(splitId)
    if splitId then
      return vim.api.nvim_win_get_buf(splitId)
    end
    return vim.api.nvim_get_current_buf()
  end,
  -- buffers: Returns all buffer IDs in a tab (defaults to current tab)
  buffers = function(tabId)
    local bufferIds = {}
    F.each(F.splits(tabId), function(splitId)
      F.append(bufferIds, F.bufferId(splitId))
    end)
    return bufferIds
  end,
  -- bufferExists: Check if a buffer exists
  bufferExists = function(bufferId)
    return vim.api.nvim_buf_is_valid(bufferId)
  end,
  -- createBuffer: Creates a new buffer
  createBuffer = function()
    -- Note: false, true means: unlisted, scratch (ie. not saveable)
    return vim.api.nvim_create_buf(false, true)
  end,
  -- closeBuffer: Close a given buffer (defaults to current buffer)
  closeBuffer = function(bufferId)
    bufferId = bufferId or F.bufferId()
    vim.api.nvim_buf_delete(bufferId, { force = true })
  end,
  -- bufferCount: Returns the number of opened buffers (defaults to current tab)
  bufferCount = function(tabId)
    return #F.buffers(tabId)
  end,
  -- forEachBuffer: Apply a callback on each buffer (defaults to current tab)
  forEachBuffer = function(callback, tabId)
    F.each(F.buffers(tabId), function(bufferId)
      callback(bufferId)
    end)
  end,

  -- globalBuffers: Returns all buffer IDs from all tabs
  globalBuffers = function()
    return vim.api.nvim_list_bufs()
  end,

  -- bufferName: Returns the name/path of a buffer (defaults to current buffer)
  bufferName = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_name(bufferId)
  end,
  -- saveBuffer: Save a buffer if it can be saved (defaults to current buffer)
  saveBuffer = function(bufferId)
    bufferId = bufferId or F.bufferId()

    local filename = F.bufferName(bufferId)
    local modifiable = F.bufferOption("modifiable", bufferId)
    local modified = F.bufferOption("modified", bufferId)

    if filename == "" or not modifiable or not modified then
      return
    end

    vim.cmd("silent! w")
  end,
  -- updateBuffer: Replace the content of a buffer
  updateBuffer = function(newContent, bufferId)
    if F.isString(newContent) then
      newContent = F.split(newContent, "\n")
    end
    bufferId = bufferId or F.bufferId()
    vim.api.nvim_buf_set_lines(bufferId, 0, -1, false, newContent)
  end,
  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand("%") == ""
  end,
}
