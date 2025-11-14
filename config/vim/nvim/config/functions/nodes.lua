-- Private methods
local getParser
local wrapNode
local findNode

local M = {
  -- Get the treesitter node at cursor position
  node = function()
    local success, result = pcall(function()
      local parser = getParser()
      if not parser then
        return nil
      end

      local lineNumber = F.lineNumber() - 1 -- Convert to 0-indexed
      local col = 0

      local root = parser:parse()[1]:root()
      local rawNode = root:named_descendant_for_range(lineNumber, col, lineNumber, col)

      return wrapNode(rawNode)
    end)

    if success then
      return result
    end
    return nil
  end,

  -- Find parent node matching types
  nodeParentOfType = function(types, node)
    return findNode(types, node, function(rawNode)
      return rawNode:parent()
    end)
  end,

  -- Find next sibling node matching types
  nodeNextOfType = function(types, node)
    return findNode(types, node, function(rawNode)
      return rawNode:next_sibling()
    end)
  end,

  -- Find previous sibling node matching types
  nodePreviousOfType = function(types, node)
    return findNode(types, node, function(rawNode)
      return rawNode:prev_sibling()
    end)
  end,

  -- Find first child node matching types
  nodeChildOfType = function(types, node)
    node = node or F.node()
    if not node then
      return nil
    end

    -- Check first child
    local firstChild = wrapNode(node.__raw:child(0))
    if not firstChild then
      return nil
    end

    if F.includes(types, firstChild.type) then
      return firstChild
    end

    -- Check all first child siblings
    return findNode(types, firstChild, function(raw)
      return raw:next_sibling()
    end)
  end,

  -- Find a node of given types on a specific line
  nodeOfType = function(types, lineNumber)
    lineNumber = lineNumber or F.lineNumber()
    if lineNumber < 1 then
      return nil
    end

    local parser = getParser()
    if not parser then
      return nil
    end

    local line0Indexed = lineNumber - 1
    local root = parser:parse()[1]:root()

    local lineContent = F.line(lineNumber)
    local lineLength = #lineContent

    for col = 0, lineLength - 1 do
      local rawNode = root:named_descendant_for_range(line0Indexed, col, line0Indexed, col)
      if rawNode and F.includes(types, rawNode:type()) then
        return wrapNode(rawNode)
      end
    end

    return nil
  end,
}

-- Private functions

-- Get the treesitter parser for the current buffer
getParser = function()
  local bufferId = F.bufferId()
  local filetype = F.bufferOption("filetype", bufferId)

  if not filetype then
    return nil
  end

  local parser = vim.treesitter.get_parser(bufferId, filetype)
  if not parser then
    return nil
  end

  return parser
end

-- Wrap a raw treesitter node into a custom node object with text, range, type, and __raw
wrapNode = function(rawNode)
  if not rawNode then
    return nil
  end

  local bufferId = F.bufferId()
  return {
    text = vim.treesitter.get_node_text(rawNode, bufferId),
    range = { rawNode:range() },
    type = rawNode:type(),
    __raw = rawNode,
  }
end

-- Generic node traversal function that finds the first node matching types using a custom getNext function
findNode = function(types, node, getNext)
  node = node or F.node()
  if not node then
    return nil
  end

  local current = getNext(node.__raw)

  while current do
    if F.includes(types, current:type()) then
      return wrapNode(current)
    end
    current = getNext(current)
  end

  return nil
end

return M
