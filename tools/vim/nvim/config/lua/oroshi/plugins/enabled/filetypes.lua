-- -- Filetypes
-- -- Specific tweaks and syntax for specific filetypes
return {
  -- HTML
  -- Emmet
  -- https://github.com/mattn/emmet-vim
  -- Expand HTML/CSS abbreviations
  {
    "mattn/emmet-vim",
    ft = { "html", "vue" },
    init = function()
      vim.g.user_emmet_install_global = 0 -- Only load it on selected filetypes
      vim.g.user_emmet_leader_key = "<nop>" -- We'll define out own keybinding
    end,
  },

  -- Kitty
  -- https://github.com/fladson/vim-kitty
  -- Syntax highlighting for kitty files
  {
    "fladson/vim-kitty",
    ft = "kitty",
  },

  -- Markdown
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- Improved display of markdown files in normal mode
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("render-markdown").setup({
        heading = {
          icons = { " ", "  ", "   ", "    ", "     ", "      " },
        },
        html = {
          comment = {
            conceal = false, -- Do not hide HTML comments
          },
        },
      })
    end,
  },

  -- Vue
  -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring
  -- Allow changing commentstring based on position in file
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local nvimTsContextCommentstring = require("ts_context_commentstring")
      -- Disable CursoHold autocommand of the plugin
      nvimTsContextCommentstring.setup({
        enable_autocmd = false,
      })

      -- Overwrite get_option to recalculate commentstring based on position in file
      local originalGetOption = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        if option ~= "commentstring" then
          return originalGetOption(filetype, option)
        end

        return nvimTsContextCommentstring.calculate_commentstring()
      end
    end,
  },
}
