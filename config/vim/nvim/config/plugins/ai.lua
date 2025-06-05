return {
  -- https://github.com/yetone/avante.nvim
  -- Avante: AI chat
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "openai",
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
    -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
    -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    -- "zbirenbaum/copilot.lua", -- for providers='copilot'
    -- {
    --   -- support for image pasting
    --   "HakonHarnes/img-clip.nvim",
    --   event = "VeryLazy",
    --   opts = {
    --     -- recommended settings
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = {
    --         insert_mode = true,
    --       },
    --       -- required for Windows users
    --       use_absolute_path = true,
    --     },
    --   },
    -- },
    -- {
    --   -- Make sure to set this up properly if you have lazy=true
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   opts = {
    --     file_types = { "markdown", "Avante" },
    --   },
    --   ft = { "markdown", "Avante" },
    -- },
  },



  -- -- https://github.com/robitx/gp.nvim
  -- -- AI Chat in right panel
  -- "robitx/gp.nvim",
  -- config = function()
  --   local gp = require('gp')
  --   gp.setup({
  --     providers = {
  --       openai = {
  --         endpoint = "https://api.openai.com/v1/chat/completions",
  --         secret = __.env("OPENAI_GP_NVIM_API_KEY")
  --       }
  --     },
  --     chat_user_prefix = "uuu>>>:",
  --     chat_template = "# topic: ?\n\n"
  --       .. "- file: %s\n"
  --       .. "---\n"
  --       .. "🗨: "
  --   })
  --
  --   -- Keybindings {{{
  --   local function toggleChat()
  --     vim.cmd('GpChatToggle vsplit')
  --     vim.cmd.wincmd('L')
  --   end
  --   nmap('⒤', toggleChat, 'Toggle AI Chat')
  --   -- }}}
  --
  --   -- autocmd {{{
  --   ftset("*nvim/gp/chats*", "markdown.chat")
  --   ftplugin( 'markdown.chat', function()
  --     vim.opt_local.number = false
  --     vim.opt_local.signcolumn = "no"
  --   end)
  --   -- }}}
  --
  -- end,
}
