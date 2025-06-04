return {
  -- https://github.com/robitx/gp.nvim
  -- AI Chat in right panel
  "robitx/gp.nvim",
  config = function()
    local gp = require('gp')
    gp.setup({
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1/chat/completions",
          secret = __.env("OPENAI_GP_NVIM_API_KEY")
        }
      },
      chat_user_prefix = "uuu>>>:",
      chat_template = "# topic: ?\n\n"
        .. "- file: %s\n"
        .. "---\n"
        .. "🗨: "
    })

    -- Keybindings {{{
    local function toggleChat()
      vim.cmd('GpChatToggle vsplit')
      vim.cmd.wincmd('L')
    end
    nmap('⒤', toggleChat, 'Toggle AI Chat')
    -- }}}

    -- autocmd {{{
    ftset("*nvim/gp/chats*", "markdown.chat")
    ftplugin( 'markdown.chat', function()
      vim.opt_local.number = false
      vim.opt_local.signcolumn = "no"
    end)
    -- }}}

  end,
}
