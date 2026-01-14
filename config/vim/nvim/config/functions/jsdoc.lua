local M = {}

local FUNCTION_TYPES = { "function_declaration", "method_definition" }
local COMMENT_TYPES = { "comment" }

-- Private functions
local findFunctionNode
local insertJsDocAboveNode

M.generateJsDoc = function()
  local functionNode = findFunctionNode()
  if not functionNode then
    return
  end

  local prompt = [[Generate a JSDoc comment for the following JavaScript/TypeScript function.

Rules:
- Return ONLY the JSDoc comment, no explanation
- Start with /** and end with */
- Include @param for each parameter with type and description
- Include @returns with type and description
- Keep descriptions concise and clear
- Do not include any markdown code blocks or extra formatting

Function code:
]] .. functionNode.text

  F.aiPrompt(prompt, function(jsdoc)
    insertJsDocAboveNode(jsdoc, functionNode)
  end)
end

-- Recursively finds a function node from the current position
findFunctionNode = function(lineNumber)
  lineNumber = lineNumber or F.lineNumber()
  local node = F.node(lineNumber)
  if not node then
    return nil
  end

  local functionNode = nil

  -- Checking if function on the specific line
  functionNode = F.nodeOnLineOfType(FUNCTION_TYPES, lineNumber)
  if functionNode then
    return functionNode
  end

  -- Checking if function in a parent node
  functionNode = F.nodeParentOfType(FUNCTION_TYPES, node)
  if functionNode then
    return functionNode
  end

  -- Checking if function after this comment
  if F.includes(COMMENT_TYPES, node.type) then
    local lineAfterComment = node.range[3] + 2
    return findFunctionNode(lineAfterComment)
  end

  return nil
end

-- Inserts or replaces a JSDoc comment above the given node
insertJsDocAboveNode = function(jsdoc, node)
  -- Get indentation from node's first line
  local nodeStartLine = node.range[1] + 1
  local indentation = F.line(nodeStartLine):match("^(%s*)")

  -- Apply indentation to each JSDoc line
  local indentedLines = F.map(F.split(jsdoc, "\n"), function(line)
    return indentation .. line
  end)
  local indentedJsdoc = F.join(indentedLines, "\n")

  local commentNode = F.nodeOnLineOfType(COMMENT_TYPES, nodeStartLine - 1)

  local startLine, endLine
  if commentNode then
    startLine = commentNode.range[1] + 1
    endLine = commentNode.range[3] + 1
  else
    startLine = nodeStartLine
    endLine = nodeStartLine - 1
  end

  F.replaceLines(indentedJsdoc, { startLine, endLine })
end

return M
