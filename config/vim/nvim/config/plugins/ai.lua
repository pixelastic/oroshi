return {
  "robitx/gp.nvim",
  config = function()
    local conf = {
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1/chat/completions",
          secret = __.env("OPENAI_GP_NVIM_API_KEY")
        }
      }
    }
    require("gp").setup(conf)
  end,
}
