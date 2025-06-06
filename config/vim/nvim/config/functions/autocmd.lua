return {
  -- autocmd: Trigger a callback on specific events
  autocmd = function(event, callback, userOptions)
    local defaults = {
      pattern = '*', -- Apply on all files by default
      callback = callback
    }
    local options = F.merge(defaults, userOptions)

    -- Can't have both pattern and buffer
    if options.buffer then options.pattern = nil end

    vim.api.nvim_create_autocmd(event, options)
  end,

  -- ftdetect: Trigger a callback when files of a specific pattern are opened
  ftdetect = function(pattern, callback, userOptions)
    local options = F.merge({ pattern = pattern }, userOptions)
    F.autocmd({ 'BufRead', 'BufNewFile' }, callback, options)
  end,

  -- ftset: Set a specific filetype on files of a specific pattern
  ftset = function(pattern, filetype)
    F.ftdetect(pattern, function()
      vim.bo.filetype = filetype
    end)
  end,

  -- ftplugin: Helper function to run a custom function on specific filetypes
  ftplugin = function(filetypes, callback, userOptions)
    local options = F.merge({ pattern = filetypes }, userOptions)
    F.autocmd('FileType', callback, options)
  end
}
