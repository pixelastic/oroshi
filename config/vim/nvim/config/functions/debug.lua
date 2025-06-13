return {
  -- debug: Display a variable
  debug = function(input)
    local displayedInput = input
    if F.isCollection(input) then
      displayedInput = vim.inspect(input)
    end
    if input == nil then
      displayedInput = 'nil'
    end

    vim.notify(displayedInput, vim.log.levels.DEBUG)
  end,


}
