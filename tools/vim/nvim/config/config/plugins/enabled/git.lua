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
          ["i"] = false,
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
          ["<cr>"] = function()
            -- Find file undercursor
            local neogitStatus = require("neogit").status
            local instance = neogitStatus.instance()
            local ui = instance.buffer.ui
            local item = ui:get_item_under_cursor()
            if not item then
              return
            end
            local filepath = item.absolute_path

            -- Open it in new tab
            F.openTab(filepath, { focus = false })
          end,

          ["1"] = F.noop,
          ["2"] = F.noop,
          ["3"] = F.noop,
          ["4"] = F.noop,
          ["I"] = F.noop,
          ["Q"] = F.noop,
          ["S"] = F.noop,
          ["Y"] = F.noop,
          ["i"] = F.noop,
          ["s"] = F.noop,
          ["x"] = F.noop,
          ["$"] = F.noop,
          ["<c-j>"] = F.noop,
          ["<c-k>"] = F.noop,
          ["<c-t>"] = F.noop,
          ["<c-v>"] = F.noop,
          ["<c-x>"] = F.noop,
          ["<s-cr>"] = F.noop,
          ["<tab>"] = F.noop,
          ["[c"] = F.noop,
          ["]c"] = F.noop,
        },
        commit_editor = {
          ["<c-s>"] = "Submit",
          ["<c-d>"] = "Abort",
        },
        commit_editor_I = {
          ["<c-s>"] = "Submit",
          ["<c-d>"] = "Abort",
        },
      },
    },
  },
}
