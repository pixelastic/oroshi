local M = {}

local FUNCTION_TYPES = { "function_declaration", "arrow_function", "function", "method_definition" }
local COMMENT_TYPES = { "comment" }
local DEFINITION_LINE_TYPES = { "export_statement" }

local function findFunctionNode(node)
  node = node or F.node()

  if not node then
    return nil
  end

  -- Case 1: Already in a function
  local functionNode = F.nodeClosest(FUNCTION_TYPES, node)
  if functionNode then
    return functionNode
  end

  -- Case 2: In a definition line (export_statement, etc.), find first child function
  local definitionNode = F.nodeClosest(DEFINITION_LINE_TYPES, node)
  if definitionNode then
    return F.nodeChildOfType(FUNCTION_TYPES, definitionNode)
  end

  -- Case 3: In a function header comment, find function definition and recurse
  local commentNode = F.nodeClosest(COMMENT_TYPES, node)
  if commentNode then
    local functionDefinitionNode = F.nodeNextOfType(DEFINITION_LINE_TYPES, commentNode)

    if functionDefinitionNode then
      return findFunctionNode(functionDefinitionNode)
    end

    return nil
  end

  return nil
end

M.generateJsDoc = function()
  local node = findFunctionNode()
  F.debug(node)
end

return M

-- local function isInJsDoc(line)
--   return line and (line:match("^%s*/%*%*") or line:match("^%s*%*") or line:match("^%s*%*/"))
-- end
--
-- local function findJsDocEnd(startLine)
--   local maxLine = math.min(F.lineCount() - 1, startLine + 100)
--   for i = startLine, maxLine do
--     if F.line(i + 1):match("^%s*%*/") then
--       return i
--     end
--   end
--   return nil
-- end
--
-- local function findJsDocStart(endLine)
--   local minLine = math.max(0, endLine - 100)
--   for i = endLine, minLine, -1 do
--     if F.line(i + 1):match("^%s*/%*%*") then
--       return i
--     end
--   end
--   return nil
-- end
--
-- local function findFunctionNode(root, line)
--   local functionTypes = { "function_declaration", "arrow_function", "function", "method_definition" }
--
--   local function search(node)
--     if F.includes(functionTypes, node:type()) then
--       local startLine, _, endLine = node:range()
--       if line >= startLine and line <= endLine then
--         return node
--       end
--     end
--
--     for child in node:iter_children() do
--       local found = search(child)
--       if found then
--         return found
--       end
--     end
--   end
--
--   return search(root)
-- end
--
-- local function getApiKey()
--   local apiKey = vim.fn.getenv("ANTHROPIC_API_KEY")
--   if apiKey == vim.NIL or apiKey == "" then
--     return nil
--   end
--   return apiKey
-- end
--
-- local function buildApiRequest(functionCode)
--   local prompt = "Generate a JSDoc comment for this JavaScript function. Return ONLY the JSDoc comment block (starting with /** and ending with */). No markdown code blocks, no additional text, no explanations.\n\nFunction:\n"
--     .. functionCode
--
--   return vim.fn.json_encode({
--     model = "claude-sonnet-4-20250514",
--     max_tokens = 1024,
--     messages = { { role = "user", content = prompt } },
--   })
-- end
--
-- local function callAnthropicAPI(functionCode, onSuccess)
--   local apiKey = getApiKey()
--   if not apiKey then
--     F.error("ANTHROPIC_API_KEY not set in environment")
--     return
--   end
--
--   local tmpRequest = vim.fn.tempname()
--   local tmpResponse = vim.fn.tempname()
--
--   vim.fn.writefile({ buildApiRequest(functionCode) }, tmpRequest)
--
--   local cmd = string.format(
--     'curl -s https://api.anthropic.com/v1/messages -H "x-api-key: %s" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" -d @%s > %s',
--     apiKey,
--     tmpRequest,
--     tmpResponse
--   )
--
--   vim.fn.jobstart(cmd, {
--     on_exit = function(_, exit_code)
--       vim.schedule(function()
--         vim.fn.delete(tmpRequest)
--
--         if exit_code ~= 0 then
--           F.error("Failed to call Anthropic API")
--           vim.fn.delete(tmpResponse)
--           return
--         end
--
--         local responseLines = vim.fn.readfile(tmpResponse)
--         vim.fn.delete(tmpResponse)
--
--         if F.isEmpty(responseLines) then
--           F.error("Empty response from API")
--           return
--         end
--
--         local responseJson = vim.fn.json_decode(F.join(responseLines, "\n"))
--
--         if responseJson.error then
--           F.error("API Error: " .. (responseJson.error.message or "Unknown"))
--           return
--         end
--
--         if not responseJson.content or F.isEmpty(responseJson.content) then
--           F.error("No content in API response")
--           return
--         end
--
--         onSuccess(responseJson.content[1].text)
--       end)
--     end,
--   })
-- end
--
--
-- local function findExistingJsDoc(functionStartLine)
--   local lineBeforeFunction = F.line(functionStartLine)
--   if lineBeforeFunction and lineBeforeFunction:match("%*/%s*$") then
--     return findJsDocStart(functionStartLine - 1)
--   end
--   return nil
-- end
--
-- local function extractFunctionCode(startLine, endLine)
--   local functionLines = vim.api.nvim_buf_get_lines(0, startLine, endLine + 1, false)
--   return F.join(functionLines, "\n"), functionLines[1]:match("^(%s*)")
-- end
--
-- local function formatJsDoc(jsdoc, indent)
--   jsdoc = F.trim(jsdoc:gsub("```[%w]*\n", ""):gsub("```", ""))
--   return F.map(F.split(jsdoc, "\n"), function(line)
--     return indent .. line
--   end)
-- end
--
-- local function insertJsDoc(jsdocLines, jsdocStartLine, functionStartLine)
--   local insertLine = jsdocStartLine or functionStartLine
--   vim.api.nvim_buf_set_lines(F.bufferId(), insertLine, functionStartLine, false, jsdocLines)
-- end
--
-- -- Exported functions
--
