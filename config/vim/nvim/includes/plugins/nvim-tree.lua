return {
  "nvim-tree/nvim-tree.lua",
  version = "1.12.0",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local nvimtree = require("nvim-tree")

    -- Disable netrw as to not interfere with the tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nmap("<C-!>", "<cmd>NvimTreeToggle<CR>", "Toggle file explorer")
    imap("<C-!>", "<ESC><cmd>NvimTreeToggle<CR>", "Toggle file explorer")

    local function onAttach(bufnr)
      local api = require "nvim-tree.api"

      -- H: Go up one level {{{
      local function onH()
        api.tree.change_root_to_parent()
      end
      nmap('h', onH, 'Go up one level', { buffer = bufnr })
      --- }}}

      -- L / Right: {{{
      --   on folders: Open/Close
      --   on files: Open in new tabs silently
      local function onL()
        local node = api.tree.get_node_under_cursor()

        -- Directories
        if node.nodes ~= nil then
         api.node.open.edit()
         return
        end

        -- Files
        local currentTab = vim.fn.tabpagenr()
        api.node.open.tab_drop(node) -- Open in new tab, or re-use existing if possible
        vim.cmd.tabnext(currentTab)  -- Go back to initial tab
        api.tree.open()              -- Keep focus on the tree
      end
      nmap('l', onL, 'Open silently', { buffer = bufnr })
      nmap('<Right>', onL, 'Open silently', { buffer = bufnr })
      --- }}}

      -- ENTER: {{{
      --   on folders: Open/Close
      --   on files: Open in new tab, and close the tree
      local function onEnter()
        local node = api.tree.get_node_under_cursor()

        -- Directories
        if node.nodes ~= nil then
         api.node.open.edit()
         return
        end

        -- Files
        local currentTab = vim.fn.tabpagenr()
        api.tree.close()              -- Keep focus on the tree
        api.node.open.tab_drop(node) -- Open in new tab, or re-use existing if possible
      end
      nmap('<CR>', onEnter, 'Open immediatly', { buffer = bufnr })
      --- }}}

      -- CTRL+N: {{{
      -- Create a new file
      local function onCtrlN()
        api.fs.create()
      end
      nmap('<C-N>', onCtrlN, 'Create new file', { buffer = bufnr })
    end

    nvimtree.setup({
      view = { width = 30, },
      on_attach = onAttach,
    })
  end
}
