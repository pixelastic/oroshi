-- -- Filetypes
-- -- Specific tweaks and syntax for specific filetypes
return {
  -- Kitty
  -- https://github.com/fladson/vim-kitty
  -- Syntax highlighting for kitty files
  {
    "fladson/vim-kitty",
    ft = "kitty"
  },

  -- Markdown
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- Improved display of markdown files in normal mode
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('render-markdown').setup({
        heading = {
          icons = { ' ', '  ', '   ', '    ', '     ', '      ' },
        },
        html = {
          comment = {
            conceal = false, -- Do not hide HTML comments
          },

        },
      })
    end
  }
}
