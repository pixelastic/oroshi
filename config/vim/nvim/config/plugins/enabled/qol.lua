-- -- QoL
-- -- Quality of life improvements
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
    },
    config = function()
      local noice = require('noice')
      noice.setup({
        -- VIEWS
        -- Views represent the different UI components of Noice.
        -- The most common views are: 
        -- - notify: displayed in the top right corner, disappear afer a while
        -- - popup: floating window at the center of the screen
        -- - mini: small line at the bottom of the screen
        -- See all view configuration at:
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
        views = {
          -- Info messages
          O_info = {
            view = "mini",
            timeout = 3000,
            position = { col = "100%", row = 0 },
            win_options = {
              winhighlight = {
                Normal = "NoiceOInfoNormal"
              },
            },
          },
          -- Error messages
          O_error = {
            view = "mini",
            timeout = 5000,
            position = { col = 0, row = 0 },
            win_options = {
              winhighlight = {
                ErrorMsg = "NoiceOErrorErrorMsg"
              },
            },
          },
          -- Warning messages
          O_warning = {
            view = "mini",
            timeout = 3000,
            position = { col = "100%", row = -1 },
            win_options = {
              winhighlight = {
                Normal = "NoiceOWarningNormal"
              },
            },
          },
          -- Commandline
          O_cmdline = {
            view = "mini",
            position = { col = 0, row = -1 },
            size = { width = "100%", },
          },
        }, 
        -- ROUTES
        -- Routes define how a specific type of message should be displayed
        -- It takes a filter (what kind) and a view (how it should be displayed)
        --
        -- See :help ui-messages for all possible kinds
        --
        -- See all route configuration at:
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/routes.lua
        routes = {
          -- Hide
          { filter = { find = "lines yanked", kind = { "" }, event = "msg_show" }, opts = { skip = true }, },   -- "__ lines yanked"
          { filter = { find = "lines indented", kind = { "" }, event = "msg_show" }, opts = { skip = true }, }, -- "__ lines indented"
          -- Warning
          { filter = { find = "No items found at position", kind = { "echo"}, event = "msg_show" }, view = "O_warning" },
        },
        -- Use a tiny commandline at the bottom of the screen
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
        messages = {
          enabled = true, -- enables the Noice messages UI
          view = "O_info", -- default view for messages
          view_error = "O_error", -- view for errors
          view_warn = "O_warning", -- view for warnings
          -- view_history = "messages", -- view for :messages
          view_search = false, -- view for search count messages. Set to `false` to disable
        },
        popupmenu = {
          enabled = true, -- enables the Noice popupmenu UI
          ---@type 'nui'|'cmp'
          backend = "nui", -- backend to use to show regular cmdline completions
          -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
          kind_icons = {}, -- set to `false` to disable icons
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
        -- default options for require('noice').redirect
        -- see the section on Command Redirection
        redirect = {
          view = "popup",
          filter = { event = "msg_show" },
        },
        -- You can add any custom commands below that will be available with `:Noice command`
        commands = {
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
          all = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {},
          },
        },
        lsp = {
          progress = {
            enabled = true,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            format = "lsp_progress",
            format_done = "lsp_progress_done",
            throttle = 1000 / 30, -- frequency to update lsp progress message
            view = "mini",
          },
          override = {
            -- override the default lsp markdown formatter with Noice
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            -- override the lsp markdown formatter with Noice
            ["vim.lsp.util.stylize_markdown"] = false,
            -- override cmp documentation with Noice (needs the other options to work)
            ["cmp.entry.get_documentation"] = false,
          },
          hover = {
            enabled = true,
            silent = false, -- set to true to not show a message if hover is not available
            view = nil, -- when nil, use defaults from documentation
            opts = {}, -- merged with defaults from documentation
          },
          signature = {
            enabled = true,
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
        status = {}, --- @see section on statusline components
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/format.lua
        format = {


        }, --- @see section on formatting
     })
    end,
  },
  -- ScrollEOF
  -- https://github.com/Aasim-A/scrollEOF.nvim
  -- Keep current line always in the middle of screen
  {
    'Aasim-A/scrollEOF.nvim',
    event = { 'CursorMoved', 'WinScrolled' },
  }
}
