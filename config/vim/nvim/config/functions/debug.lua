local convertInput = function(input)
  local displayedInput = input
  if F.isCollection(input) then
    displayedInput = vim.inspect(input)
  end
  if input == nil then
    displayedInput = 'nil'
  end

  return displayedInput
end

return {
  -- error: All past errors, in a split
  error = function(input)
    local output = convertInput(input)
    vim.notify(output, vim.log.levels.ERROR)
  end,

  -- warn: Warning message as notification
  warn = function(input)
    local output = convertInput(input)
    vim.notify(output, vim.log.levels.WARN)
  end,

  -- Info: Info message as notification
  info = function(input)
    local output = convertInput(input)
    vim.notify(output, vim.log.levels.INFO)
  end,

  -- debug: only last message in a split
  debug = function(input)
    local output = convertInput(input)
    vim.notify(output, vim.log.levels.DEBUG)

    require('noice').cmd('showLastDebug')
  end,
}
