return {
  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs_staged_enable = false,
      signcolumn = false,
      numhl = true,
      signs = {
        add = { text = "█" },
        change = { text = "▌" },
        changedelete = { text = "▌" },
        delete = { text = "▌" },
        topdelete = { text = "▌" },
        untracked = { text = "┆" },
      },
    },
  },

  -- Neogit for git operations
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "Neogit",
    opts = {
      kind = "floating",
      integrations = {
        diffview = false,
      },
      mappings = {
        popup = {
          -- Disable advanced functions, so I can use regular mappings
          ["r"] = false,
          ["l"] = false,
        },
        status = {
          ["j"] = "MoveDown",
          ["k"] = "MoveUp",
          ["{"] = "GoToPreviousHunkHeader",
          ["}"] = "GoToNextHunkHeader",

          ["<c-r>"] = "RefreshBuffer",
          ["<c-o>"] = "OpenTree", -- Open GitHub

          ["za"] = "Toggle",
          ["f"] = "Stage",
          ["F"] = "StageAll",
          ["u"] = "Unstage",
          ["U"] = "UnstageStaged",
          ["R"] = "Discard",
          ["q"] = "Close",

          ["y"] = "ShowRefs", -- TODO: Need to style it
          ["<cr>"] = function()
            local neogitStatus = require("neogit").status
            local instance = neogitStatus.instance()
            local ui = instance.buffer.ui
            local item = ui:get_item_under_cursor()
            if not item then
              return
            end
            local filepath = item.absolute_path

            F.openTab(filepath, { focus = false })
          end,

          ["<tab>"] = F.noop,

          ["I"] = F.noop,
          ["1"] = F.noop,
          ["2"] = F.noop,
          ["3"] = F.noop,
          ["4"] = F.noop,
          ["Q"] = F.noop,
          ["s"] = F.noop,
          ["S"] = F.noop,
          ["x"] = F.noop,
          ["$"] = F.noop,
          ["Y"] = F.noop,
          ["<s-cr>"] = F.noop,
          ["<c-v>"] = F.noop,
          ["<c-x>"] = F.noop,
          ["<c-t>"] = F.noop,
          ["[c"] = F.noop,
          ["]c"] = F.noop,
          ["<c-k>"] = F.noop,
          ["<c-j>"] = F.noop,
        },
      },
    },
  },
}
