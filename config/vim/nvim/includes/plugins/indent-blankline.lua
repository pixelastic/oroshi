return {
  -- https://github.com/lukas-reineke/indent-blankline.nvim
  -- Show the "scope" I'm in currently
  -- enabled = false,
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    -- TODO: Change the colors, to make it grey when unused and a bit mor visible
    -- when used. This seems useful, but I'll need to tweak the colors first
    -- Currently disabled until I've changed the colors
    -- require("ibl").setup({
    --   indent = { char = "┊" },
    -- })

  end
}
