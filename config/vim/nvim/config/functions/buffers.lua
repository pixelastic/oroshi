return {
  -- isNoName: Check if the buffer is a [No Name] buffer, when vim is opened
  -- without a filepath
  isNoName = function()
    return vim.fn.expand("%") == ""
  end,
  -- bufferId: Returns current buffer id
  bufferId = function()
    return vim.api.nvim_get_current_buf()
  end,
  -- createBuffer: Creates a new buffer
  createBuffer = function()
    -- Note: false, true means: unlisted, scratch (ie. not saveable)
    return vim.api.nvim_create_buf(false, true)
  end,
  -- closeBuffer: Close a given buffer
  closeBuffer = function(bufferId)
    vim.api.nvim_buf_delete(bufferId, { force = true })
  end,
  -- bufferOption: Return the value of a specific buffer option
  bufferOption = function(bufferId, optionName)
    return vim.api.nvim_get_option_value(optionName, { buf = bufferId })
  end,
  -- bufferLines: Returns a collection of all lines in a buffer
  bufferLines = function(bufferId)
    return vim.api.nvim_buf_get_lines(bufferId, 0, -1, false)
  end,
}
