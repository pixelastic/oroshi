local ftplugin = F.ftplugin
local autocmd = F.autocmd
local nmap = F.nmap
local imap = F.imap
local vmap = F.vmap

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
        provider = "claude",
        mode = "legacy",
        auto_set_keymap = false,
        enable_token_counting = false,
      })

      local avante = require('avante.init')
      local avanteApi = require('avante.api')

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

        autocmd('VimResized', setChatWidth, { buffer = F.bufferId() })
      end)
      -- }}}

      -- getTabWindows: Find which window is code, or avante {{{
      local function getTabWindows()
        local windows = {}
        local ignoreList = { 'notify', 'help'}

        for _, windowId in ipairs(vim.api.nvim_list_wins()) do
          local bufferId = vim.api.nvim_win_get_buf(windowId)
          local filetype = vim.api.nvim_buf_get_option(bufferId, 'filetype')

          -- Skip useless windows
          if filetype == "" or F.includes(ignoreList, filetype) then
            goto continue
          end
          -- Avante Response
          if filetype == 'Avante' then 
            windows.avante = windowId
            goto continue
          end
          -- Avante Input
          if filetype == 'AvanteInput' then 
            windows.avanteInput = windowId
            goto continue
          end

          -- Code (pick the oldest)
          if not windows.code or windowId < windows.code then
            windows.code = windowId
          end

          ::continue::
        end

        return windows
      end
      -- }}}

      -- Switching between Chat and Code {{{
      -- <C-I> opens the chat, or navigate between chat and code
      local function switchBetweenChatAndCode()
        local windows = getTabWindows()

        -- Open if not yet opened
        if not windows.avante then
          avanteApi.ask({ without_selection = true })
          F.normalMode()
          return
        end

        -- Move between code and Avante
        local currentWindow = F.windowId()
        local nextWindow = windows.code
        if currentWindow == windows.code then nextWindow = windows.avanteInput end
        F.focusWindow(nextWindow)
      end
      nmap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
      imap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
      vmap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
      -- }}}

      -- Toggle the display of the Chat window {{{
      local function toggleChat()
        F.normalMode()
        local windows = getTabWindows()

        -- If opened, we close it
        if windows.avante then
          F.focusWindow(windows.avante)
          vim.cmd('q!')
          return
        end

        -- Otherwise, we show it
        avanteApi.ask({ without_selection = true })
      end
      nmap('Ⓘ', toggleChat, 'Toggle Chat')
      imap('Ⓘ', toggleChat, 'Toggle Chat')
      vmap('Ⓘ', toggleChat, 'Toggle Chat')
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
      ftplugin({ 'Avante', 'AvanteInput' }, function()
        local buffer = vim.api.nvim_get_current_buf()
        nmap('<C-N>', newChat, 'New AI Chat', { buffer = buffer })
        imap('<C-N>', newChat, 'New AI Chat', { buffer = buffer })
      end)
      -- }}}

      -- Chat history {{{
      local function chatHistory()
        __.normalMode()
        avanteApi.select_history()
      end
      nmap('<C-F>', chatHistory, 'Show Chat History')
      imap('<C-F>', chatHistory, 'Show Chat History')
      -- }}}

      -- Display {{{
      ftplugin('Avante', function()
        vim.opt_local.colorcolumn = "0" -- Hide text wrap limit
      end)



      ftplugin('AvanteInput', function()
        local bufferId = F.getBufferId()
        local rawFilepath = vim.fn.expand('%:p')

        -- TODO: Change the cursor when entering/leaving
        -- vim.opt_local.guicursor:append("n:block-CursorModeAiResponse") -- Change cursor in response
        -- vim.opt_local.guicursor:append("i:hor25-CursorModeAiPrompt") -- Change cursor in input
        -- autocmd('BufEnter', nil, function()
        --   __.debug('enter')
        -- end, { buffer = bufferId })
        -- -- vim.api.nvim_create_autocmd('BufEnter', {
        --
        -- --   buffer = bufferId,
        -- --   pattern = nil,
        -- --   callback = function() 
        -- --     __.debug('enter')
        -- --   end
        -- -- })
        -- vim.api.nvim_create_autocmd('BufLeave', {
        --   buffer = bufferId,
        --   pattern = nil,
        --   callback = function() 
        --     __.debug('leave')
        --   end
        -- })
      end)
      -- }}}

    end
  }
}
