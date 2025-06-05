return {
  -- https://github.com/yetone/avante.nvim
  -- Avante: AI chat
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local avantePlugin = require('avante')
      avantePlugin.setup({
        mode = "legacy",
        auto_set_keymap = false,
        enable_token_counting = false,
        provider = "openai",
      })

      local avante = require('avante.init')
      local avanteApi = require('avante.api')

      -- Toggle Chat {{{
      local function toggleChat()
        vim.cmd.stopinsert() -- Go back to normal mode

        -- Open new one if not yet opened
        if not avante.is_sidebar_open() then
          avanteApi.ask({
            without_selection = true
          })
          return
        end

        -- Close existing one
        avante.close_sidebar()
      end
      nmap('⒤', toggleChat, 'Toggle AI Chat')
      imap('⒤', toggleChat, 'Toggle AI Chat')
      -- }}}

      -- Chat flexible width {{{
      local function setChatWidth()
        local maxWidth = vim.o.columns;
        local widthFullScreen = 62
        local widthSmallScreen = 50
        local chatWidth = maxWidth > 73 and widthFullScreen or widthSmallScreen
        vim.api.nvim_win_set_width(0, chatWidth)
      end
      ftplugin('Avante', function()
        setChatWidth()

        local buffer = vim.api.nvim_get_current_buf()
        autocmd('VimResized', "*", setChatWidth, { buffer = buffer })
      end)
      -- }}}
      
      -- New chat {{{
      local function newChat()
        -- If chat is already opened, close it before staring a new one
        if avante.is_sidebar_open() then
          avante.close_sidebar()
        end

        avanteApi.ask({ 
          new_chat = true,
          without_selection = true 
        })
      end
      nmap('Ⓘ', newChat, 'New AI Chat')
      imap('Ⓘ', newChat, 'New AI Chat')
      -- }}}

      -- Chat history {{{
      local function chatHistory()
        vim.cmd.stopinsert() -- Go back to normal mode
        avanteApi.select_history()
      end
      nmap('<C-H>', chatHistory, 'Show Chat History')
      imap('<C-H>', chatHistory, 'Show Chat History')
      -- }}}

      ftplugin('Avante', function()
        vim.opt_local.colorcolumn = "0" 
      end)



      
    end
  }
}
