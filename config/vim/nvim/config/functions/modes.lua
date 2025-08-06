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
    return mode == 'v' or mode == 'V' or mode == ''
  end,
  -- isVisualLineMode: Check if in visual line
  isVisualLineMode = function()
    return vim.fn.mode() == 'V'
  end,

  -- normalMode: Switch to normal mode
  normalMode = function()
    if F.isVisualMode() then
      vim.api.nvim_command('normal ') -- Press <Esc>
      return
    end

    vim.cmd.stopinsert()
  end,
  -- insertMode: Switch to insert mode
  insertMode = function()
    vim.cmd.startinsert()
  end,
}
