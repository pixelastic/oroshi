local ftplugin = F.ftplugin
local autocmd = F.autocmd
local nmap = F.nmap
local imap = F.imap
local vmap = F.vmap
local hl = F.hl

return {
  {
    "github/copilot.vim",
  },

  -- https://github.com/yetone/avante.nvim
  -- Avante: AI chat
  {
    "yetone/avante.nvim",
    enabled = false,
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
        providers = {
          claude = {
            -- TODO: Mapping in insert mode, home should go to beginning of first chars, not beginning of line
            -- TODO: C-C in the Avante window to cancel a request
            -- TODO: Seems like opening the chat again in a new vim windows doesn't allow to continue the conversation
            -- TODO: Opening the side chat should be per tab. So I can open two of them in two tabs
            -- TODO: I might need to find a way to refresh them from one tab to the next

            -- rag_search, python, git_diff, git_commit, list_files, search_files, search_keyword, read_file_toplevel_symbols, read_file, create_file, rename_file, delete_file, create_dir, rename_dir, delete_dir, bash, web_search, fetch
            disable_tools = true,
          }

        },
        mode = "legacy",
        auto_set_keymap = false,
        enable_token_counting = false,
      })

      local avante = require('avante.init')
      local avanteApi = require('avante.api')

      -- Chat flexible width {{{
      local function setChatWidth()
        local maxWidth = vim.o.columns;
        local widthFullScreen = 75
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
        local tabId = vim.api.nvim_get_current_tabpage()

        for _, windowId in ipairs(vim.api.nvim_tabpage_list_wins(tabId)) do
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

      -- Cursor {{{
      ftplugin('AvanteInput', function()
        local bufferId = F.bufferId()

        -- Set custom cursor when entering
        autocmd('WinEnter', function()
          vim.schedule(function()
            F.setGuicursor('i', 'hor25', 'CursorModeInsert')
            hl('CursorModeNormal', 'none', O.colors.cursor.ai)
            hl('CursorModeInsert', 'none', O.colors.cursor.ai)
          end)
        end, { buffer = bufferId })

        -- Revert to normal cursor when leaving
        autocmd('WinLeave', function()
          F.setGuicursor('i', 'ver25', 'CursorModeInsert')
          hl('CursorModeNormal', 'none', O.colors.cursor.normal)
          hl('CursorModeInsert', 'none', O.colors.cursor.insert)
        end, { buffer = bufferId })
      end)
      -- }}}

      -- Display {{{
      ftplugin('Avante', function()
        vim.opt_local.colorcolumn = "0" -- Hide text wrap limit
      end)
      -- }}}

    end
  },


  -- -- https://github.com/olimorris/codecompanion.nvim
  -- -- Codecompanion
  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {},
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     local codecompanion = require('codecompanion')
  --     codecompanion.setup({
  --       strategies = {
  --         chat = {
  --           adapter = "anthropic",
  --         },
  --       },
  --       opts = {
  --         log_level = "DEBUG",
  --       },
  --     })
  --   end
  -- },
}
