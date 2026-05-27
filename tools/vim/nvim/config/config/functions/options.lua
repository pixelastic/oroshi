return {
  -- option: Returns the value of an option (tries buffer first, then split)
  option = function(name)
    local ok, value = pcall(F.bufferOption, name)
    if ok then
      return value
    end
    return F.splitOption(name)
  end,
  -- updateOption: Update an option (tries buffer first, then split)
  updateOption = function(name, value)
    local ok = pcall(F.updateBufferOption, name, value)
    if not ok then
      F.updateSplitOption(name, value)
    end
  end,
  -- bufferOption: Returns the value of a buffer option (defaults to current buffer)
  bufferOption = function(name, bufferId)
    bufferId = bufferId or F.bufferId()
    return vim.api.nvim_get_option_value(name, { buf = bufferId })
  end,
  -- updateBufferOption: Update a buffer option (defaults to current buffer)
  updateBufferOption = function(name, value, bufferId)
    bufferId = bufferId or F.bufferId()
    vim.api.nvim_set_option_value(name, value, { buf = bufferId })
  end,
  -- splitOption: Returns the value of a split option (defaults to current split)
  splitOption = function(name, splitId)
    splitId = splitId or F.splitId()
    return vim.api.nvim_get_option_value(name, { win = splitId })
  end,
  -- updateSplitOption: Update a split option (defaults to current split)
  updateSplitOption = function(name, value, splitId)
    splitId = splitId or F.splitId()
    vim.api.nvim_set_option_value(name, value, { win = splitId })
  end,
}
