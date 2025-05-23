function map(mode, input, output, description, options)
  local defaults = { 
    silent = true, 
    noremap = true,
    nowait = true,
    desc = description, 
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  vim.keymap.set(mode, input, output, config)
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
