local ftplugin = F.ftplugin
local autocmd = F.autocmd
local nmap = F.nmap
local imap = F.imap
local vmap = F.vmap

-- This is code example taken from https://github.com/hrsh7th/nvim-cmp/discussions/1034
-- ['<C-o>'] = cmp.mapping(function(fallback)
--   local fallback_key = vim.api.nvim_replace_termcodes('<Tab>', true, true, true)
--   local resolved_key = vim.fn['copilot#Accept'](fallback)
--   if fallback_key == resolved_key then
--     cmp.confirm({ select = true })
--   else
--     vim.api.nvim_feedkeys(resolved_key, 'n', true)
--   end
-- end),
-- TODO: Copilot as ghost text and manual completion for completion?

return {
  -- Copilot: Suggest code as I type
  -- https://github.com/zbirenbaum/copilot.lua
  -- Note: I'm using a .lua version, not the official github/copilot.vim plugin
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot = require("copilot")
      local commands = require("copilot.command")

      copilot.setup({
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 500,
          keymap = {
            accept = false, -- We'll handle Tab manually
            accept_word = false,
            accept_line = false,
            next = "<C-k>",
            prev = "<C-j>",
            dismiss = "<C-c>",
          },
        },
        filetypes = {
          -- yaml = false,
          -- markdown = false,
          -- help = false,
          -- gitcommit = false,
          -- gitrebase = false,
          -- hgcommit = false,
          -- svn = false,
          -- cvs = false,
          -- ["."] = false,
        },
        -- should_attach = function(_, _)
        --   if not vim.bo.buflisted then
        --     logger.debug("not attaching, buffer is not 'buflisted'")
        --     return false
        --   end
        --
        --   if vim.bo.buftype ~= "" then
        --     logger.debug("not attaching, buffer 'buftype' is " .. vim.bo.buftype)
        --     return false
        --   end
        --
        --   return true
        -- end,
      })
      O.statusline.copilotLoaded = true

      local function toggleCopilot()
        commands.toggle()

        -- Update statusline
        vim.b.statuslineCopilotDisabled = not vim.b.statuslineCopilotDisabled
        vim.cmd("redrawstatus")
      end
      nmap("<F12>", toggleCopilot, "Toggle Copilot")
      imap("<F12>", toggleCopilot, "Toggle Copilot")
    end,
  },

  -- Codecompanion
  -- https://github.com/olimorris/codecompanion.nvim
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- CodeCompanionChat to open the buffer
      -- Why display on left?
      -- Doesn't include the file by default
      local codecompanion = require("codecompanion")
      codecompanion.setup({
        strategies = {
          chat = {
            adapter = "copilot",
            keymaps = {
              send = {
                modes = { n = "<C-CR>", i = "<C-CR>" },
                -- modes = { n = "<F99>", i = "<F99>" },
              },
              close = {
                modes = { n = "<F99>", i = "<F99>" }, -- Map to a nonexistent key to disable it
              },
            },
          },
          inline = {
            adapter = "anthropic",
          },
          -- cmd = {
          --   adapter = "deepseek",
          -- }
        },
        display = {
          chat = {
            window = {
              layout = "float",
              width = 0.8,
              title = {
                { "", "CodeCompanionChatTitleDecoration" },
                { " AI Chat ", "CodeCompanionChatTitle" },
                { "", "CodeCompanionChatTitleDecoration" },
              },
              border = {
                { "▄", "CodeCompanionChatBorder" },
                { "▄", "CodeCompanionChatBorder" },
                { "▄", "CodeCompanionChatBorder" },
                { "█", "CodeCompanionChatBorder" },
                { "▀", "CodeCompanionChatBorder" },
                { "▀", "CodeCompanionChatBorder" },
                { "▀", "CodeCompanionChatBorder" },
                { "█", "CodeCompanionChatBorder" },
              },
              opts = {
                winhighlight = F.join({
                  "Normal:CodeCompanionChatNormal",
                  "EndOfBuffer:CodeCompanionChatEndOfBuffer",
                  "@markup.heading.2.markdown:CodeCompanionChatInnerTitle",
                }, ","),
              },
            },
            intro_message = "",
            auto_scroll = false,
            show_token_count = false,
          },
          -- diff = {
          --   enabled = true,
          --   close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          --   layout = "vertical", -- vertical|horizontal split for default provider
          --   opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
          --   provider = "default", -- default|mini_diff
          -- },
        },
        opts = {
          log_level = "DEBUG",
        },
      })

      local function whenThinkingStarts(callback)
        autocmd("User", callback, { pattern = "CodeCompanionRequestStarted" })
      end
      local function whenThinkingEnds(callback)
        autocmd("User", callback, { pattern = "CodeCompanionRequestFinished" })
      end

      -- Open chat window {{{
      local function openChatWindow()
        codecompanion.toggle()
      end
      nmap("⒤", openChatWindow, "Open the chat window")
      imap("⒤", openChatWindow, "Open the chat window")
      vmap("⒤", "<cmd>CodeCompanionChat<CR><CR><CR>", "Open the chat window")
      -- }}}

      -- Specific bindings and config of the chat window {{{
      ftplugin("codecompanion", function()
        local bufferId = F.bufferId()

        -- Ctrl-B to add #buffer
        imap("<C-B>", "#buffer<CR>", "Add #buffer", { buffer = bufferId })
        nmap("<C-B>", "mZ^i#buffer<CR><Esc>`Zj", "Add #buffer", { buffer = bufferId })

        -- Various ways to close the window
        local function closeChatWindow()
          F.normalMode()
          codecompanion.toggle()
        end
        nmap("⒤", closeChatWindow, "Close the window", { buffer = bufferId })
        nmap("<C-C>", closeChatWindow, "Close the window", { buffer = bufferId })
        nmap("<C-D>", closeChatWindow, "Close the window", { buffer = bufferId })
        imap("⒤", closeChatWindow, "Close the window", { buffer = bufferId })
        imap("<C-C>", closeChatWindow, "Close the window", { buffer = bufferId })
        imap("<C-D>", closeChatWindow, "Close the window", { buffer = bufferId })
        vmap("⒤", closeChatWindow, "Close the window", { buffer = bufferId })
        vmap("<C-C>", closeChatWindow, "Close the window", { buffer = bufferId })
        vmap("<C-D>", closeChatWindow, "Close the window", { buffer = bufferId })

        -- imap('<C-CR>', function()
        --   local chat = require('codecompanion/strategies/chat')
        --   F.debug(chat)
        --   chat:submit()
        -- end, "Close the window", { buffer = bufferId })

        -- Init
        autocmd("BufEnter", function()
          vim.wo.number = false -- Hide line numbers
          vim.wo.colorcolumn = "0" -- Hide wrap column

          -- Start in insert mode if no question has been asked
          local isConversationStarted = F.get(O.codecompanion[bufferId], "isConversationStarted")
          if not isConversationStarted then
            F.insertMode()
          end
        end, { buffer = bufferId })
      end)
      -- }}}

      -- Update colors while thinking {{{
      whenThinkingStarts(function()
        F.hl("CodeCompanionChatBorder", "none", O.colors.codecompanion.thinking.chatBorder)
        F.hl("CodeCompanionChatNormal", "none", O.colors.codecompanion.thinking.chatNormal)
      end)
      whenThinkingEnds(function()
        F.hl("CodeCompanionChatBorder", "none", O.colors.codecompanion.default.chatBorder)
        F.hl("CodeCompanionChatNormal", "none", O.colors.codecompanion.default.chatNormal)
      end)
      -- }}}

      -- Keep state in memory {{{
      whenThinkingStarts(function(event)
        local bufferId = event.buf
        O.codecompanion[bufferId] = {
          isConversationStarted = true,
        }
      end)
      -- }}}
      --
      --
      --
      -- local windowId = F.windowId()
      -- if not O.diagnostics[windowId] then
      --   O.diagnostics[windowId] = {}
      -- end
      -- return O.diagnostics[windowId]
    end,
  },

  -- -- https://github.com/yetone/avante.nvim
  -- -- Avante: AI chat
  -- {
  --   "yetone/avante.nvim",
  --   enabled = false,
  --   event = "VeryLazy",
  --   version = false,
  --   build = "make",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   config = function()
  --     local avantePlugin = require('avante')
  --     avantePlugin.setup({
  --       provider = "claude",
  --       providers = {
  --         claude = {
  --           -- TODO: Mapping in insert mode, home should go to beginning of first chars, not beginning of line
  --           -- TODO: C-C in the Avante window to cancel a request
  --           -- TODO: Seems like opening the chat again in a new vim windows doesn't allow to continue the conversation
  --           -- TODO: Opening the side chat should be per tab. So I can open two of them in two tabs
  --           -- TODO: I might need to find a way to refresh them from one tab to the next
  --
  --           -- rag_search, python, git_diff, git_commit, list_files, search_files, search_keyword, read_file_toplevel_symbols, read_file, create_file, rename_file, delete_file, create_dir, rename_dir, delete_dir, bash, web_search, fetch
  --           disable_tools = true,
  --         }
  --
  --       },
  --       mode = "legacy",
  --       auto_set_keymap = false,
  --       enable_token_counting = false,
  --     })
  --
  --     local avante = require('avante.init')
  --     local avanteApi = require('avante.api')
  --
  --     -- Chat flexible width {{{
  --     local function setChatWidth()
  --       local maxWidth = vim.o.columns;
  --       local widthFullScreen = 75
  --       local widthSmallScreen = 50
  --       local chatWidth = maxWidth > 73 and widthFullScreen or widthSmallScreen
  --       vim.api.nvim_win_set_width(0, chatWidth)
  --     end
  --     ftplugin('Avante', function()
  --       setChatWidth()
  --
  --       autocmd('VimResized', setChatWidth, { buffer = F.bufferId() })
  --     end)
  --     -- }}}
  --
  --     -- getTabWindows: Find which window is code, or avante {{{
  --     local function getTabWindows()
  --       local windows = {}
  --       local ignoreList = { 'notify', 'help'}
  --       local tabId = vim.api.nvim_get_current_tabpage()
  --
  --       for _, windowId in ipairs(vim.api.nvim_tabpage_list_wins(tabId)) do
  --         local bufferId = vim.api.nvim_win_get_buf(windowId)
  --         local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufferId })
  --
  --         -- Skip useless windows
  --         if filetype == "" or F.includes(ignoreList, filetype) then
  --           goto continue
  --         end
  --         -- Avante Response
  --         if filetype == 'Avante' then
  --           windows.avante = windowId
  --           goto continue
  --         end
  --         -- Avante Input
  --         if filetype == 'AvanteInput' then
  --           windows.avanteInput = windowId
  --           goto continue
  --         end
  --
  --         -- Code (pick the oldest)
  --         if not windows.code or windowId < windows.code then
  --           windows.code = windowId
  --         end
  --
  --         ::continue::
  --       end
  --
  --       return windows
  --     end
  --     -- }}}
  --
  --     -- Switching between Chat and Code {{{
  --     -- <C-I> opens the chat, or navigate between chat and code
  --     local function switchBetweenChatAndCode()
  --       local windows = getTabWindows()
  --
  --       -- Open if not yet opened
  --       if not windows.avante then
  --         avanteApi.ask({ without_selection = true })
  --         F.normalMode()
  --         return
  --       end
  --
  --       -- Move between code and Avante
  --       local currentWindow = F.windowId()
  --       local nextWindow = windows.code
  --       if currentWindow == windows.code then nextWindow = windows.avanteInput end
  --       F.focusWindow(nextWindow)
  --     end
  --     nmap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
  --     imap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
  --     vmap('⒤', switchBetweenChatAndCode, 'Switch between Chat and Code')
  --     -- }}}
  --
  --     -- Toggle the display of the Chat window {{{
  --     local function toggleChat()
  --       F.normalMode()
  --       local windows = getTabWindows()
  --
  --       -- If opened, we close it
  --       if windows.avante then
  --         F.focusWindow(windows.avante)
  --         vim.cmd('q!')
  --         return
  --       end
  --
  --       -- Otherwise, we show it
  --       avanteApi.ask({ without_selection = true })
  --     end
  --     nmap('Ⓘ', toggleChat, 'Toggle Chat')
  --     imap('Ⓘ', toggleChat, 'Toggle Chat')
  --     vmap('Ⓘ', toggleChat, 'Toggle Chat')
  --     -- }}}
  --
  --     -- New chat {{{
  --     local function newChat()
  --       -- If chat is already opened, close it before staring a new one
  --       if avante.is_sidebar_open() then
  --         avante.close_sidebar()
  --       end
  --
  --       avanteApi.ask({
  --         new_chat = true,
  --         without_selection = true
  --       })
  --     end
  --     ftplugin({ 'Avante', 'AvanteInput' }, function()
  --       local buffer = vim.api.nvim_get_current_buf()
  --       nmap('<C-N>', newChat, 'New AI Chat', { buffer = buffer })
  --       imap('<C-N>', newChat, 'New AI Chat', { buffer = buffer })
  --     end)
  --     -- }}}
  --
  --     -- Chat history {{{
  --     local function chatHistory()
  --       F.normalMode()
  --       avanteApi.select_history()
  --     end
  --     nmap('<C-F>', chatHistory, 'Show Chat History')
  --     imap('<C-F>', chatHistory, 'Show Chat History')
  --     -- }}}
  --
  --     -- Cursor {{{
  --     ftplugin('AvanteInput', function()
  --       local bufferId = F.bufferId()
  --
  --       -- Set custom cursor when entering
  --       autocmd('WinEnter', function()
  --         vim.schedule(function()
  --           F.setGuicursor('i', 'hor25', 'CursorModeInsert')
  --           hl('CursorModeNormal', 'none', O.colors.cursor.ai)
  --           hl('CursorModeInsert', 'none', O.colors.cursor.ai)
  --         end)
  --       end, { buffer = bufferId })
  --
  --       -- Revert to normal cursor when leaving
  --       autocmd('WinLeave', function()
  --         F.setGuicursor('i', 'ver25', 'CursorModeInsert')
  --         hl('CursorModeNormal', 'none', O.colors.cursor.normal)
  --         hl('CursorModeInsert', 'none', O.colors.cursor.insert)
  --       end, { buffer = bufferId })
  --     end)
  --     -- }}}
  --
  --     -- Display {{{
  --     ftplugin('Avante', function()
  --       vim.opt_local.colorcolumn = "0" -- Hide text wrap limit
  --     end)
  --     -- }}}
  --
  --   end
  -- },
}
