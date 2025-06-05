return {
  -- isInsertMode: Check if we are in Insert mode
  isInsertMode = function()
    return vim.api.nvim_get_mode().mode == 'i'
  end,
  -- isSearchMode: Check if in search mode
  isSearchMode = function()
    return vim.fn.mode()  == 'c' and vim.fn.getcmdtype() == '/'
  end,
  -- isCommandMode: Check if in command mode
  isCommandMode = function()
    return vim.fn.mode()  == 'c' and vim.fn.getcmdtype() == ':'
  end,
  -- isVisualMode: Check if in visual mode
  isVisualMode = function()
    local mode = vim.fn.mode()
    return mode == 'v' or mode == 'V' or mod == ''
  end,

  -- normalMode: Switch to normal mode
  normalMode = function()
    vim.api.nvim_command('normal ') -- Press <Esc>
  end,
  -- insertMode: Switch to insert mode
  insertMode = function()
    vim.cmd.startinsert()
  end,
}
