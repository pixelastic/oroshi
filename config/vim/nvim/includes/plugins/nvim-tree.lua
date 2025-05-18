return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- Disable netrw as to not interfere with the tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local function onAttach(bufnr)
      local api = require "nvim-tree.api"

      local function map(input, output, desc)
	 vim.keymap.set('n', input, output, { desc = desc, buffer = bfnr, noremap = true, silent = true, nowait = true })
      end


      -- H: Go up one level {{{
      local function onH()
        api.tree.change_root_to_parent()
      end
      map('h', onH, 'Go up one level')
      --- }}}

      -- L: {{{
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
      map('l', onL, 'Open silently')
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
      map('<CR>', onEnter, 'Open immediatly')
      --- }}}
    end

    nmap("<C-!>", "<cmd>NvimTreeToggle<CR>", "Toggle file explorer")

    nvimtree.setup({
      view = {
        width = 30,
      },
      on_attach = onAttach,
      -- change folder arrow icons
      -- renderer = {
      --   indent_markers = {
      --     enable = true,
      --   },
      --   icons = {
      --     glyphs = {
      --       folder = {
      --         arrow_closed = "", -- arrow when folder is closed
      --         arrow_open = "", -- arrow when folder is open
      --       },
      --     },
      --   },
      -- },
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      -- actions = {
      --   open_file = {
      --     window_picker = {
      --       enable = false,
      --     },
      --   },
      -- },
      -- filters = {
      --   custom = { ".DS_Store" },
      -- },
      -- git = {
      --   ignore = false,
      -- },
    })
  end
}
