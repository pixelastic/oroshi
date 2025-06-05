return {
  -- debug: Display a variable
  debug = function(input)
    local displayedInput = input
    if F.isCollection(input) then
      displayedInput = vim.inspect(input)
    end

    vim.schedule(function()
      local success, error = pcall(function()
        vim.notify(displayedInput, vim.log.levels.INFO)
      end)
      if error then
        vim.print(displayedInput)
      end
    end)
  end,


}
