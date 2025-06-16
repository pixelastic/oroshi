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

    vim.print(displayedInput)
    -- TODO: What I prooably need to do here is to:
    -- call a specific method, either print, or notify, or something else
    -- Catch it in noice conifiguratoin to not display it, but add it to the
    -- history
    -- then use noice history (in reverse order) to display the split window
    -- that way, I can have a shared split for all messages, displayed in
    -- reversed order
    -- But for that, I need to understand how to call something to be caught by
    -- noice, and how to add it to the history
  end,


}
