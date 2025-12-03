return {
  -- absolute: Convert path to absolute path
  absolute = function(...)
    local parts = { ... }
    local path = table.concat(parts, "/")
    return vim.fn.expand(path)
  end,

  -- deleteFile: Delete a file from the filesystem
  deleteFile = function(path)
    vim.fn.delete(path)
  end,

  -- shellEscape: Escape filepath for CLI
  -- Ex: 'path/with spaces.txt'
  shellEscape = function(path)
    return vim.fn.shellescape(path)
  end,

  -- fileEscape: Escape filepath for internal commands
  -- Ex: path/with\ spaces.txt
  fileEscape = function(path)
    return vim.fn.fnameescape(path)
  end,

  -- here: Absolute path to current file
  here = function()
    return vim.fn.expand("%:p")
  end,

  -- readFile: Read the content of a file and return it as a string
  readFile = function(path)
    local expandedPath = vim.fn.expand(path)
    local ok, lines = pcall(vim.fn.readfile, expandedPath)
    if not ok or not lines then
      return nil
    end
    return vim.fn.trim(table.concat(lines, "\n"))
  end,
}
