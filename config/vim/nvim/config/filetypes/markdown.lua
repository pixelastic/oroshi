local vmap = F.vmap
local nmap = F.nmap

-- Wrap the selection in the given strings
local toggleWrapping = function(before, after)
  -- Use the same string for both sides if only one is provided
  if not after then
    after = before
  end

  return function()
    local selection = F.getSelection()
    local canBeToggled = before == after
    local startsWithWrap = F.startsWith(F.first(selection), before)
    local endsWithWrap = F.endsWith(F.last(selection), after)
    local isAlreadyWrapped = startsWithWrap and endsWithWrap

    -- failsafe so if we cannot revert, we do nothing
    if isAlreadyWrapped and not canBeToggled then
      F.normalMode()
      return
    end

    if isAlreadyWrapped then
      -- Remove the wrapping
      selection[1] = F.replace(selection[1], before, '')
      selection[#selection] = F.replace(selection[#selection], after, '')
    else
      -- Add the wrapping
      selection[1] = before .. selection[1]
      selection[#selection] = selection[#selection] .. after
    end

    F.replaceSelection(selection)

  end
end

-- Select the current word and call the callback
local selectWordAnd = function(callback)
  return function()
    F.selectWord()
    callback()
  end
end

-- Wrap the selection in a link using the clipboard content
local wrapSelectionInLink = function()
  local clipboard = vim.fn.getreg('*')
  toggleWrapping('[', '](' .. clipboard .. ')')()
end

F.ftplugin('markdown', function()
  local bufferId = F.bufferId()

  -- Bold and code visual selection
  vmap('`', toggleWrapping('`'), 'Code', { buffer = bufferId })
  vmap('r', toggleWrapping('`'), 'Code', { buffer = bufferId })
  vmap('b', toggleWrapping('**'), 'Bold text', { buffer = bufferId })

  -- Bold and code word under cursor
  nmap('``', selectWordAnd(toggleWrapping('`')), 'Put word in code', { buffer = bufferId })
  nmap('<C-R>', selectWordAnd(toggleWrapping('`')), 'Put word in code', { buffer = bufferId })
  nmap('<C-B>', selectWordAnd(toggleWrapping('**')), 'Bold word', { buffer = bufferId })

  -- Wrap selection in link
  vmap(']]', wrapSelectionInLink, 'Wrap selection in link', { buffer = bufferId })
  nmap(']]', selectWordAnd(wrapSelectionInLink), 'Wrap selection in link', { buffer = bufferId })
end)
