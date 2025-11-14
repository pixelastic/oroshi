local M = {}

local COMMENT_TYPES = { "comment" }
local DEFINITION_LINE_TYPES = { "export_statement" }
local FUNCTION_BODY_TYPES = { "statement_block" }
local FUNCTION_TYPES = { "function_declaration" }

-- Forward declarations
local findFunctionNode
local insertJsDoc

M.updateJsDoc = function()
  local node = findFunctionNode()
  if not node then
    return
  end

  local prompt = "Generate a JSDoc comment for this JavaScript function. Return ONLY the JSDoc comment block (starting with /** and ending with */). No markdown code blocks, no additional text, no explanations.\n\nFunction:\n"
    .. node.text
  F.aiPrompt(prompt, function(jsdoc)
    insertJsDoc(jsdoc, node)
  end)
end

-- Private functions

-- Returns the node containing the function. Works when cursor is in the
-- function body, on the export line, or in the JSDoc comment
findFunctionNode = function(node)
  node = node or F.node()
  if not node then
    return nil
  end

  -- Case 1: In comment - find next export_statement and recurse
  if F.includes(COMMENT_TYPES, node.type) then
    local exportNode = F.nodeNextOfType(DEFINITION_LINE_TYPES, node)
    if exportNode then
      return findFunctionNode(exportNode)
    end
    return nil
  end

  -- Case 2: On export line - get first child function
  if F.includes(DEFINITION_LINE_TYPES, node.type) then
    return F.nodeChildOfType(FUNCTION_TYPES, node)
  end

  -- Case 3: In function body (statement_block) - find parent function
  if F.includes(FUNCTION_BODY_TYPES, node.type) then
    return F.nodeParentOfType(FUNCTION_TYPES, node)
  end

  return nil
end

-- Inserts the given JSDoc above the given function node. Will replace any
-- existing JSDoc, if any.
insertJsDoc = function(jsdoc, functionNode)
  local declarationNode = F.nodeParentOfType(DEFINITION_LINE_TYPES, functionNode)

  local existingJsDoc = F.nodePreviousOfType(COMMENT_TYPES, declarationNode)
  local startLine, endLine
  if existingJsDoc then
    -- Replace existing JSDoc (treesitter uses 0-indexed, convert to 1-indexed)
    startLine = existingJsDoc.range[1] + 1
    endLine = existingJsDoc.range[3] + 1
  else
    -- Insert new JSDoc before declaration (treesitter uses 0-indexed, convert to 1-indexed)
    startLine = declarationNode.range[1] + 1
    endLine = declarationNode.range[1]
  end

  F.updateLines(jsdoc, startLine, endLine)
end

return M
