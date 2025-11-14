local M = {}

local MODEL_NAME = "claude-sonnet-4-20250514"
local ANTHROPIC_VERSION = "2023-06-01"
local ANTHROPIC_URL = "https://api.anthropic.com/v1/messages"
local ANTHROPIC_API_KEY = vim.fn.getenv("ANTHROPIC_API_KEY")

local function setThinkingIndicator(isThinking)
  O.statusline.ai = { isThinking = isThinking }
  vim.cmd("redrawstatus")
end

-- Call Anthropic API with a prompt and execute callback with the response
-- @param prompt string - The prompt to send to the AI
-- @param onSuccess function - Callback function called with the AI response text
M.aiPrompt = function(prompt, onSuccess)
  if not ANTHROPIC_API_KEY then
    F.error("ANTHROPIC_API_KEY not set")
    return
  end

  local body = vim.fn.json_encode({
    model = MODEL_NAME,
    max_tokens = 1024,
    messages = { { role = "user", content = prompt } },
  })

  setThinkingIndicator(true)

  F.httpRequest(ANTHROPIC_URL, {
    method = "POST",
    headers = {
      ["x-api-key"] = ANTHROPIC_API_KEY,
      ["anthropic-version"] = ANTHROPIC_VERSION,
      ["content-type"] = "application/json",
    },
    body = body,
    onSuccess = function(responseBody)
      setThinkingIndicator(false)

      local responseJson = vim.fn.json_decode(responseBody)

      if responseJson.error then
        F.error("API Error: " .. (responseJson.error.message or "Unknown"))
        return
      end

      if not responseJson.content or F.isEmpty(responseJson.content) then
        F.error("No content in API response")
        return
      end

      onSuccess(responseJson.content[1].text)
    end,
    onError = function(error)
      setThinkingIndicator(false)
      F.error("API Error: " .. error)
    end,
  })
end

return M
