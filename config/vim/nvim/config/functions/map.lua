local function map(mode, input, output, description, userOptions)
  local defaults = {
    silent = true,
    noremap = true,
    nowait = true,
    expr = false,
    desc = description,
  }
  local options = F.merge(defaults, userOptions)

  vim.keymap.set(mode, input, output, options)
end

return {
  -- Below functions should be used as:
  -- nmap('{what to type}', '{what it should do}', '{description}')
  nmap = function(input, output, description, options)
    map("n", input, output, description, options)
  end,
  imap = function(input, output, description, options)
    map("i", input, output, description, options)
  end,
  vmap = function(input, output, description, options)
    map("x", input, output, description, options)
  end,
  cmap = function(input, output, description, options)
    map("c", input, output, description, options)
  end,

  -- Apply map only when completion menu is opened
  ccmpmap = function(input, output, description, userOptions)
    local function ifCompletionVisible()
      return vim.fn.pumvisible() == 1 and output or input
    end
    local options = F.merge({ expr = true, silent = false }, userOptions)
    F.cmap(input, ifCompletionVisible, description, options)
  end
}
