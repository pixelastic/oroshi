local M = {}

local FUNCTION_TYPES = { "function_declaration", "method_definition" }
local COMMENT_TYPES = { "comment" }

-- Private functions
local insertJsDocAboveNode

M.generateJsDoc = function()
  local node = F.node()
  if not node then
    return
  end

  local functionNode

  -- If we're in a comment, look for a function on the line after the comment
  if F.includes(COMMENT_TYPES, node.type) then
    functionNode = F.nodeOfType(FUNCTION_TYPES, node.range[3] + 2)
  else
    -- Find function on current line or in parents
    functionNode = F.nodeOfType(FUNCTION_TYPES) or F.nodeParentOfType(FUNCTION_TYPES)
  end

  if not functionNode then
    return
  end

  -- Hardcoded JSDoc for testing
  local jsdoc =
    "/**\n * This is a test JSDoc comment\n * @param {string} param1 - First parameter\n * @returns {void}\n */"

  insertJsDocAboveNode(jsdoc, functionNode)
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

  local commentNode = F.nodeOfType(COMMENT_TYPES, nodeStartLine - 1)

  local startLine, endLine
  if commentNode then
    startLine = commentNode.range[1] + 1
    endLine = commentNode.range[3] + 1
  else
    startLine = nodeStartLine
    endLine = nodeStartLine - 1
  end

  F.updateLines(indentedJsdoc, startLine, endLine)
end

return M
