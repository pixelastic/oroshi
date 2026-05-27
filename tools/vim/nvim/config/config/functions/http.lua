local M = {}

-- Make an HTTP request using curl
-- @param url string - The URL to request
-- @param options table - Request options
--   - method string - HTTP method (default: "GET")
--   - headers table - HTTP headers as key-value pairs
--   - body string - Request body (for POST, PUT, etc.)
--   - onSuccess function - Callback called with response body
--   - onError function - Callback called with error message (optional, defaults to F.error)
M.httpRequest = function(url, options)
  options = options or {}
  local method = options.method or "GET"
  local headers = options.headers or {}
  local body = options.body
  local onSuccess = options.onSuccess
  local onError = options.onError or function(error)
    F.error("API Error: " .. error)
  end

  local tmpResponse = vim.fn.tempname()
  local tmpBody = nil

  -- Build curl command
  local cmd = string.format('curl --silent --request %s "%s"', method, url)
  for key, value in pairs(headers) do
    cmd = cmd .. string.format(' --header "%s: %s"', key, value)
  end

  if body then
    tmpBody = vim.fn.tempname()
    vim.fn.writefile({ body }, tmpBody)
    cmd = cmd .. string.format(" --data @%s", tmpBody)
  end

  -- Output to temp file
  cmd = cmd .. string.format(" > %s", tmpResponse)

  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      vim.schedule(function()
        -- Cleanup temp files
        if tmpBody then
          F.deleteFile(tmpBody)
        end

        if exit_code ~= 0 then
          F.deleteFile(tmpResponse)
          onError("HTTP request failed with exit code " .. exit_code)
          return
        end

        local responseBody = F.readFile(tmpResponse)
        F.deleteFile(tmpResponse)

        if not responseBody or responseBody == "" then
          onError("Empty response from server")
          return
        end

        onSuccess(responseBody)
      end)
    end,
  })
end

return M
