-- -- Filetypes
-- -- Specific tweaks and syntax for specific filetypes
return {
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
