local M = {}

local FUNCTION_TYPES = { "function_declaration", "arrow_function", "function", "method_definition" }
local COMMENT_TYPES = { "comment" }
local DEFINITION_LINE_TYPES = { "export_statement" }

-- Forward declarations
local findFunctionNode
local insertJsDoc

M.updateJsDoc = function()
  -- Stop if not in a function
  local node = findFunctionNode()
  if not node then
    return
  end

  -- Generate a new JSDoc and update it in the code
  local prompt = "Generate a JSDoc comment for this JavaScript function. Return ONLY the JSDoc comment block (starting with /** and ending with */). No markdown code blocks, no additional text, no explanations.\n\nFunction:\n"
    .. node.text
  F.aiPrompt(prompt, function(jsdoc)
    insertJsDoc(jsdoc, node)
  end)
end

-- Private functions

-- Returns the node containing the function. Should work when cursor is inside
-- the function, on the function defition line, or on the JSDoc comment above
-- the function
findFunctionNode = function(node)
  node = node or F.node()

  if not node then
    return nil
  end

  -- Case 1: Already in a function
  local functionNode = F.nodeParentOfType(FUNCTION_TYPES, node)
  if functionNode then
    return functionNode
  end

  -- Case 2: In a definition line (export_statement, etc.), find first child function
  local definitionNode = F.nodeParentOfType(DEFINITION_LINE_TYPES, node)
  if definitionNode then
    return F.nodeChildOfType(FUNCTION_TYPES, definitionNode)
  end

  -- Case 3: In a function header comment, find function definition and recurse
  local commentNode = F.nodeParentOfType(COMMENT_TYPES, node)
  if commentNode then
    local functionDefinitionNode = F.nodeNextOfType(DEFINITION_LINE_TYPES, commentNode)

    if functionDefinitionNode then
      return findFunctionNode(functionDefinitionNode)
    end

    return nil
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
