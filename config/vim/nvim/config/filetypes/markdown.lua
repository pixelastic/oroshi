local M = {}

M.onFiletype = function()
  local bufferId = F.bufferId()
  local vmap = F.vmap
  local nmap = F.nmap

  -- Bold and code visual selection
  vmap("`", M.__.toggleWrapping("`"), "Code", { buffer = bufferId })
  vmap("`", M.__.toggleWrapping("`"), "Code", { buffer = bufferId })
  vmap("r", M.__.toggleWrapping("`"), "Code", { buffer = bufferId })
  vmap("b", M.__.toggleWrapping("**"), "Bold text", { buffer = bufferId })

  -- Bold and code word under cursor
  nmap("``", M.__.selectWordAnd(M.__.toggleWrapping("`")), "Put word in code", { buffer = bufferId })
  nmap("<C-R>", M.__.selectWordAnd(M.__.toggleWrapping("`")), "Put word in code", { buffer = bufferId })
  nmap("<C-B>", M.__.selectWordAnd(M.__.toggleWrapping("**")), "Bold word", { buffer = bufferId })

  -- Wrap selection in link
  vmap("]]", M.__.wrapSelectionInLink, "Wrap selection in link", { buffer = bufferId })
  nmap("]]", M.__.selectWordAnd(M.__.wrapSelectionInLink), "Wrap selection in link", { buffer = bufferId })
end

M.__ = {
  -- Wrap the selection in the given strings
  toggleWrapping = function(before, after)
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
        selection[1] = F.replace(selection[1], before, "")
        selection[#selection] = F.replace(selection[#selection], after, "")
      else
        -- Add the wrapping
        selection[1] = before .. selection[1]
        selection[#selection] = selection[#selection] .. after
      end

      F.replaceSelection(selection)
    end
  end,

  -- Select the current word and call the callback
  selectWordAnd = function(callback)
    return function()
      F.selectWord()
      callback()
    end
  end,

  -- Wrap the selection in a link using the clipboard content
  wrapSelectionInLink = function()
    local clipboard = vim.fn.getreg("*")
    M.__.toggleWrapping("[", "](" .. clipboard .. ")")()
  end,
}

return M
