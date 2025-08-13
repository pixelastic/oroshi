return {
  -- bufferId: Returns current buffer id
  bufferId = function()
    return vim.api.nvim_get_current_buf()
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
  -- allBuffers: Returns all buffer IDs
  allBuffers = function()
    return vim.api.nvim_list_bufs()
  end,
  -- forEachBuffer: Apply a callback on each buffer
  forEachBuffer = function(callback)
    F.each(F.allBuffers(), function(bufferId)
      callback(bufferId)
    end)
  end,
  -- bufferName: Returns the name/path of a buffer (defaults to current buffer)
  bufferName = function(bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_buf_get_name(bufferId)
  end,
  -- bufferOption: Return the value of a specific buffer option (defaults to current buffer)
  bufferOption = function(bufferId, optionName)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_get_option_value(optionName, { buf = bufferId })
  end,

  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand("%") == ""
  end,
}
