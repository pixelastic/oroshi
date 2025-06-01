function map(mode, input, output, description, userOptions)
  local defaults = {
    silent = true,
    noremap = true,
    nowait = true,
    expr = false,
    desc = description,
  }
  local options = __._.merge(defaults, userOptions)

  vim.keymap.set(mode, input, output, options)
end
-- Below functions should be used as:
-- nmap('{what to type}', '{what it should do}', '{description}')
function imap(input, output, description, options)
  map("i", input, output, description, options)
end
function nmap(input, output, description, options)
  map("n", input, output, description, options)
end
function vmap(input, output, description, options)
  map("x", input, output, description, options)
end
function cmap(input, output, description, options)
  map("c", input, output, description, options)
end

-- Apply map only when completion menu is opened
function ccmpmap(input, output, description, userOptions)
  local function ifCompletionVisible()
    return vim.fn.pumvisible() == 1 and output or input
  end
  local options = __._.merge({ expr = true, silent = false }, userOptions)
  cmap(input, ifCompletionVisible, description, options)
end
