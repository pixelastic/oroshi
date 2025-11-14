return {
  -- absolute: Convert path to absolute path
  absolute = function(...)
    local parts = { ... }
    local path = table.concat(parts, "/")
    return vim.fn.expand(path)
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

  -- deleteFile: Delete a file from the filesystem
  deleteFile = function(path)
    vim.fn.delete(path)
  end,
}
