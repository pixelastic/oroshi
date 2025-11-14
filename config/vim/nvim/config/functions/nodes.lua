local M = {}

local function getParser()
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

local function wrapNode(rawNode)
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

-- Get the treesitter node at the current cursor position
-- @return table|nil - Custom node object with text, range, type, and __raw properties, or nil if not found
M.node = function()
  local parser = getParser()
  if not parser then
    return nil
  end

  local lineNumber = F.lineNumber() - 1 -- Convert to 0-indexed
  local col = 0

  local root = parser:parse()[1]:root()
  local rawNode = root:named_descendant_for_range(lineNumber, col, lineNumber, col)

  return wrapNode(rawNode)
end

-- Find the closest parent node matching one of the specified types
-- @param types table - Array of node types to search for (e.g., {"function_declaration", "arrow_function"})
-- @param node table|nil - Custom node object to start from, defaults to current cursor node
-- @return table|nil - Custom node object of the closest matching parent, or nil if not found
M.nodeClosest = function(types, node)
  node = node or M.node()
  if not node then
    return nil
  end

  local current = node.__raw

  while current do
    if F.includes(types, current:type()) then
      return wrapNode(current)
    end
    current = current:parent()
  end

  return nil
end

-- Find the next sibling node matching one of the specified types
-- @param types table - Array of node types to search for (e.g., {"function_declaration", "arrow_function"})
-- @param node table|nil - Custom node object to start from, defaults to current cursor node
-- @return table|nil - Custom node object of the next matching sibling, or nil if not found
M.nodeNextOfType = function(types, node)
  node = node or M.node()
  if not node then
    return nil
  end

  local current = node.__raw:next_sibling()

  while current do
    if F.includes(types, current:type()) then
      return wrapNode(current)
    end
    current = current:next_sibling()
  end

  return nil
end

-- Get all next sibling nodes
-- @param node table|nil - Custom node object to start from, defaults to current cursor node
-- @return table - Array of custom node objects for all following siblings
M.nodeNextAll = function(node)
  node = node or M.node()
  if not node then
    return {}
  end

  local result = {}
  local current = node.__raw:next_sibling()

  while current do
    table.insert(result, wrapNode(current))
    current = current:next_sibling()
  end

  return result
end

-- Find the first child node matching one of the specified types
-- @param types table - Array of node types to search for (e.g., {"function_declaration", "arrow_function"})
-- @param node table|nil - Custom node object to start from, defaults to current cursor node
-- @return table|nil - Custom node object of the first matching child, or nil if not found
M.nodeChildOfType = function(types, node)
  node = node or M.node()
  if not node then
    return nil
  end

  for child in node.__raw:iter_children() do
    if F.includes(types, child:type()) then
      return wrapNode(child)
    end
  end

  return nil
end

return M
