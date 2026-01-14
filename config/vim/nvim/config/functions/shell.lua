local M = {}

-- Run a shell command asynchronously
-- @param command string - Command to execute
-- @param options table - { onSuccess = function(), onError = function() }
M.run = function(command, userOptions)
  local defaults = {
    onSuccess = F.noop,
    onError = F.noop,
  }
  local options = F.merge(defaults, userOptions)

  vim.system({ command }, {}, function(result)
    local output = {
      stdout = F.trim(result.stdout),
      stderr = F.trim(result.stderr),
      code = result.code,
    }
    F.defer(function()
      if result.code ~= 0 then
        options.onError(output)
        return
      end

      options.onSuccess(output)
    end)
  end)
end

return M
