-- UI
-- Changes to the Nvim UI
return {
  -- Noice
  -- https://github.com/folke/noice.nvim
  -- Replaces the UI of messages, CmdLine and popupmenu
  -- Note: I couldn't get show_pos() to work with that, it was displayed in a
  -- popup window and disappeared
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local noice = require('noice')
      noice.setup({
        -- Commandline
        cmdline = {
          enabled = true,
          format = {
            cmdline = { view = "O_cmdline", icon = "  ", conceal = false },
            lua = { view = "O_cmdline", icon = "  ", conceal = false },
            help = { view = "O_cmdline", icon = "  ", conceal = false },
            search_down = { view = "O_cmdline", icon = "  ", conceal = false },
            search_up = { view = "O_cmdline", icon = "  ", conceal = false },
          }
        },
        -- Routes
        -- Routes represent to which views Noice should send specific messages
        -- See :help ui-messages for all possible kinds
        -- See all route configuration at:
        --
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/routes.lua
        routes = {
          -- Keybinding mappings
          { filter = { event = "msg_show", kind = "list_cmd", find = "No mapping found" }, view = "O_warn", },
          { filter = { event = "msg_show", kind = "list_cmd" }, view = "O_temporary", },
          -- Debug colors
          { filter = { event = "msg_show", kind = "echomsg", find = "O_DEBUG_COLORS" }, opts = { skip = true, history = true} },
          -- Useless messages
          {
            filter = {
              kind = { "" },
              event = "msg_show",
              any = {
                { find = "fewer lines"},
                { find = "lines indented"},
                { find = "lines yanked"},
                { find = "more lines"},
                { find = "lines <ed"},
                { find = "lines >ed"},
              },
            },
            opts = { skip = true },
          },
          -- Debug
          { filter = { event = "notify", kind = "debug" }, opts = { skip = true, history = true }}, -- Save in history, display with :Noice showLastDebug
          -- Info
          { filter = { event = "notify", kind = "info" }, view = "O_info", },
          -- Warning
          {
            filter = {
              kind = { "emsg" },
              event = "msg_show",
              any = {
                { find = "Pattern not found"},
                { find = "E20: Mark not set"},
                { find = "E78: Unknown mark"},
              },
            },
            view = "O_warn",
          },
          { filter = { event = "notify", kind = "warn" }, view = "O_warn", },






          -- Error
          -- { filter = { event = "notify", kind = "error" }, view = "messages", },
          -- { filter = { event = "notify", kind = "debug", max_height = 10 }, view = "O_debug", }, -- F.debug()
          -- { filter = { event = "notify", kind = "debug", min_height = 10 }, view = "messages", }, -- Long debug messages

        },
        -- Messages
        messages = {
          enabled = true,
          view = "O_debug",          -- Default messages
          view_warn = "O_warn",  -- Warning messages
          view_error = "messages",  -- Error messages in their own split
          view_history = "messages",
          view_search = false,      -- Do not show search count
        },
        -- Popupmenu, used for completion
        popupmenu = {
          enabled = true,
          backend = "nui",
        },
        -- Custom views
        -- Views represent "how" Noice should display specific things
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
        views = {
          -- Commandline: Small line at the bottom left of the screen
          O_cmdline = {
            view = "mini",
            position = { col = 0, row = -1 },
            size = { width = "100%", },
          },
          -- Error: Split, with all past errors, in reverse order
          O_error = {

          },
          -- Warning: Small notification at bottom right
          O_warn = {
            view = "mini",
            relative = "editor",
            timeout = 4000,
            position = { col = "100%", row = -1 },
            format = {
              { "{message} ", hl_group = "NoiceOWarningMessage" },
              { "", hl_group = "NoiceOWarningIconSeparator" },
              { "   ", hl_group = "NoiceOWarningIcon" },
            },
          },
          -- Info: Small notification at bottom right
          O_info = {
            view = "mini",
            relative = "editor",
            timeout = 4000,
            position = { col = "100%", row = -1 },
            format = {
              { "{message} ", hl_group = "NoiceOInfoMessage" },
              { "", hl_group = "NoiceOInfoIconSeparator" },
              { "   ", hl_group = "NoiceOInfoIcon" },
            },
          },
          -- Temporary: Full-width notification at bottom of screen
          O_temporary = {
            view = "mini",
            relative = "editor",
            timeout = 10000,
            anchor = "SW",
            position = { col = 0, row = -1 },
            size = { width = "100%", },
            format = {
              "{message}"
            },
          },
          -- Debug: Split, last info message displayed
          -- Note: Do not call this view directly, it is used by F.debug
          O_debug = {
            view = "split",
            format = { "{message}" },
          },
          -- DebugColors: Split, last debugColors call
          -- Note: Do not call this view directly, it is used by F.debugColors
          O_debugColors = {
            backend = "split",
            relative = "editor",
            position = "bottom",
            enter = false,
            size = 5,
            format = { "{message}" },
            close = {
              keys = { "q" },
            },
            win_options = {
              cursorline = false,
              list = false,
              wrap = true,
            },

          },
        },
        -- You can add any custom commands below that will be available with `:Noice command`
        commands = {
          -- showLastDebug: Display the last debug message
          showLastDebug = {
            view = "O_debug",
            opts = { enter = false },
            filter = {
              any = {
                { event = "notify", kind = "debug" }
              }
            },
            filter_opts = { count = 1 },
          },
          -- showDebugColors: Display the last debugColors call
          showDebugColors = {
            view = "O_debugColors",
            opts = { enter = false },
            filter = {
              any = {
                { event = "msg_show", kind = "echomsg", find = "O_DEBUG_COLORS" }
              }
            },
            filter_opts = { count = 1 },
          },
          -- Noice all: Display (almost) all messages of history
          -- Note: I actually filter some messages out, because I couldn't find
          -- a way to NOT have them show up in the history
          all = {
            view = "split",
            opts = {
              enter = false,
              format = {
                { "--- ", hl_group = "NoiceOMessageSeparator" },
                "{level} ",
                { "{event}", hl_group = "NoiceOMessageEvent" },
                "DEBUG/title: {title}\n",
                {
                  "{kind}",
                  hl_group = "NoiceOMessageKind",
                  before = { ".", hl_group = "NoiceOMessageKind" },
                },
                "\n",
                { "{cmdline}\n", hl_group = "NoiceOMessageCmdline" },
                {
                  "{message}\n",
                  hl_group = "NoiceOMessageMessage",
                  before = { "█ ", hl_group = "NoiceOMessagePrefix" },
                },
              }
            },
            filter = {
              ['not'] = {
                event = "msg_showcmd"
              }
            },
          },



          history = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp", kind = "message" },
              },
            },
          },
          -- :Noice last
          last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp", kind = "message" },
              },
            },
            filter_opts = { count = 1 },
          },
          -- :Noice errors
          errors = {
            -- options for the message history that you get with `:Noice`
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
          },
          -- all = {
          --   -- options for the message history that you get with `:Noice`
          --   view = "split",
          --   opts = { enter = true, format = "details" },
          --   filter = {},
          -- },
        },







        -- default options for require('noice').redirect
        -- see the section on Command Redirection
        redirect = {
          view = "popup",
          filter = { event = "msg_show" },
        },
        lsp = {
          enabled = false,
          progress = { enabled = false, }, -- Disable progress bars when loading
          hover = {
            enabled = false,
            silent = true, -- set to true to not show a message if hover is not available
            view = nil, -- when nil, use defaults from documentation
            opts = {}, -- merged with defaults from documentation
          },
          override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = false,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = false,
          },
          signature = {
            enabled = false,
            auto_open = {
              enabled = true,
              trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
              luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
              throttle = 50, -- Debounce lsp signature help request by 50ms
            },
            view = nil, -- when nil, use defaults from documentation
            opts = {}, -- merged with defaults from documentation
          },
          message = {
            -- Messages shown by lsp servers
            enabled = true,
            view = "notify",
            opts = {},
          },
          -- defaults for hover and signature help
          documentation = {
            view = "hover",
            opts = {
              lang = "markdown",
              replace = true,
              render = "plain",
              format = { "{message}" },
              win_options = { concealcursor = "n", conceallevel = 3 },
            },
          },
        },
        notify = {
          -- Noice can be used as `vim.notify` so you can route any notification like other messages
          -- Notification messages have their level and other properties set.
          -- event is always "notify" and kind can be any log level as a string
          -- The default routes will forward notifications to nvim-notify
          -- Benefit of using Noice for this is the routing and consistent history view
          enabled = true,
          view = "notify",
        },
        status = {}, --- @see section on statusline components
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/format.lua
        format = {


        }, --- @see section on formatting
      })

      F.ftplugin('noice', function()
        F.nmap('<CR>', '', 'Unmap <CR>', { buffer = F.bufferId() }) -- Disable <CR>, was triggering issues
      end)
    end,
  },
}
