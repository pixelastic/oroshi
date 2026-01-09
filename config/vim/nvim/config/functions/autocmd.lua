return {
  -- autocmd: Trigger a callback on specific events
  autocmd = function(event, callback, userOptions)
    local defaults = {
      pattern = "*", -- Apply on all files by default
      callback = callback,
    }
    local options = F.merge(defaults, userOptions)

    -- Can't have both pattern and buffer
    if options.buffer then
      options.pattern = nil
    end

    vim.api.nvim_create_autocmd(event, options)
  end,

  -- onRead: Trigger a callback when files of a specific pattern are opened
  onRead = function(pattern, callback)
    local options = F.merge({ pattern = pattern })
    F.autocmd({ "BufRead", "BufNewFile" }, callback, options)
  end,

  -- onWrite: Trigger a callback when files of a specific pattern are written
  onWrite = function(pattern, callback)
    local options = F.merge({ pattern = pattern })
    F.autocmd("BufWritePost", callback, options)
  end,

  -- ftset: Set a specific filetype on files of a specific pattern
  ftset = function(pattern, filetype)
    F.onRead(pattern, function()
      vim.bo.filetype = filetype
    end)
  end,

  -- ftplugin: Helper function to run a custom function on specific filetypes
  ftplugin = function(filetypes, callback, userOptions)
    local options = F.merge({ pattern = filetypes }, userOptions)

    -- This is going to be called whenever ft= is set, so could potentially fire
    -- several times for the same file. So we add a protection, to prevent the
    -- same callback to be fired twice for the same buffer.
    local callbackId = F.substring(tostring(callback), 10)
    F.autocmd("FileType", function()
      -- We find a unique string identifying this callback, and save it in the
      -- buffer, preventing the same callback to be executed again.
      local bufferId = F.bufferId()
      local key = "oroshi_ftplugin_" .. callbackId

      if vim.b[bufferId][key] then
        return
      end
      vim.b[bufferId][key] = true

      callback()
    end, options)
  end,
}
