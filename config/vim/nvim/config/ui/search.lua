local nmap = F.nmap
local vmap = F.vmap
local autocmd = F.autocmd

vim.opt.ignorecase = true -- Case-insensitive by default...
vim.opt.smartcase = true -- ...unless an uppercase letter is used
vim.opt.incsearch = true -- Search as I type
vim.opt.hlsearch = false -- Highlight results only when asked

-- Typing ù: or :ù to search and replace
nmap("ù:", ":%s/", "Search and replace", { silent = false })
nmap("ù!", ":%s/", "Search and replace", { silent = false })
nmap(":ù", ":%s/", "Search and replace", { silent = false })
vmap("ù:", ":s/", "Search and replace", { silent = false })
vmap("ù!", ":s/", "Search and replace", { silent = false })
vmap(":ù", ":s/", "Search and replace", { silent = false })

-- Force highlight when searching
local function setHlSearch(newValue)
  return function()
    -- Only in search mode
    if F.isSearchMode() then
      vim.opt.hlsearch = newValue
    end
  end
end
autocmd("CmdlineEnter", setHlSearch(false))
autocmd("CmdlineLeave", setHlSearch(true))
