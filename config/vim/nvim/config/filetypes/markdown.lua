local vmap = F.vmap
local nmap = F.nmap

-- Wrap the selection in the given strings
local wrapSelectionIn = function(before, after)
  -- Use the same string for both sides if only one is provided
  if not after then
    after = before
  end

  return function()
    local selection = F.getSelection()
    selection[1] = before .. selection[1]
    selection[#selection] = selection[#selection] .. after
    F.replaceSelection(selection)
  end
end

-- Select the current word and call the callback
local selectWordAnd = function(callback)
  return function()
    vim.cmd.normal('viw')
    callback()
  end
end

-- Wrap the selection in a link using the clipboard content
local wrapSelectionInLink = function()
  local clipboard = vim.fn.getreg('*')
  wrapSelectionIn('[', '](' .. clipboard .. ')')()
end

F.ftplugin('markdown', function()
  local bufferId = F.bufferId()

  -- Bold and code visual selection
  vmap('`', wrapSelectionIn('`'), 'Code', { buffer = bufferId })
  vmap('r', wrapSelectionIn('`'), 'Code', { buffer = bufferId })
  vmap('b', wrapSelectionIn('**'), 'Bold text', { buffer = bufferId })

  -- Bold and code word under cursor
  nmap('``', selectWordAnd(wrapSelectionIn('`')), 'Put word in code', { buffer = bufferId })
  nmap('<C-R>', selectWordAnd(wrapSelectionIn('`')), 'Put word in code', { buffer = bufferId })
  nmap('<C-B>', selectWordAnd(wrapSelectionIn('**')), 'Bold word', { buffer = bufferId })

  -- Wrap selection in link
  vmap(']]', wrapSelectionInLink, 'Wrap selection in link', { buffer = bufferId })
  nmap(']]', selectWordAnd(wrapSelectionInLink), 'Wrap selection in link', { buffer = bufferId })
end)
