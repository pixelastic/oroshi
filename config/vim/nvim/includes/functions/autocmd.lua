function autocmd(event, pattern, callback)
  local defaults = { 
    pattern = pattern,
    callback = callback
  }
  local config = vim.tbl_deep_extend("force", defaults, options or {})

  vim.api.nvim_create_autocmd(event, config)
end

-- ftdetect: Helper function to define a custom overide of filetype
function ftdetect(pattern, callback, options)
  autocmd({ 'BufRead', 'BufNewFile' }, pattern, callback, options)
end

-- ftplugin: Helper function to run a custom function on specific filetypes
function ftplugin(pattern, callback, options)
  autocmd('FileType', pattern, callback, options)
end
