-- -- QoL
-- -- Quality of life improvements
return {
  -- Notify
  -- https://github.com/rcarriga/nvim-notify
  -- Display messages in a floating notification window
  -- {
  --   "rcarriga/nvim-notify",
  --   config = function()
  --     local notify = require('notify')
  --     notify.setup({
  --       minimum_width = 30,
  --       render = 'wrapped-compact',
  --       stages = "static"
  --     })
  --
  --     -- vim.notify = notify
  --   end
  -- },
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
        presets = {
          -- bottom_search = false, -- use a classic bottom cmdline for search
          -- command_palette = true, -- position the cmdline and popupmenu together
          -- long_message_to_split = true, -- long messages will be sent to a split
          -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
          -- lsp_doc_border = false, -- add a border to hover docs and signature help
        },
        cmdline = {
          enabled = true,
          -- opts = {}, -- global options for the cmdline. See section on views
          format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          }
          --   -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          --   -- view: (default is cmdline view)
          --   -- opts: any options passed to the view
          --   -- icon_hl_group: optional hl_group for the icon
          --   -- title: set to anything or empty string to hide
          --   filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          --   lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
          --   input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
          --   -- lua = false, -- to disable a format, set to `false`
        },

        messages = {
          -- NOTE: If you enable messages, then the cmdline is enabled automatically.
          -- This is a current Neovim limitation.
          enabled = true, -- enables the Noice messages UI
          view = "notify", -- default view for messages
          view_error = "notify", -- view for errors
          view_warn = "notify", -- view for warnings
          view_history = "messages", -- view for :messages
          view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
        },
        popupmenu = {
          enabled = true, -- enables the Noice popupmenu UI
          ---@type 'nui'|'cmp'
          backend = "nui", -- backend to use to show regular cmdline completions
          -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
          kind_icons = {}, -- set to `false` to disable icons
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
        notify = {
          -- Noice can be used as `vim.notify` so you can route any notification like other messages
          -- Notification messages have their level and other properties set.
          -- event is always "notify" and kind can be any log level as a string
          -- The default routes will forward notifications to nvim-notify
          -- Benefit of using Noice for this is the routing and consistent history view
          enabled = true,
          view = "notify",
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
        markdown = {
          hover = {
            ["|(%S-)|"] = vim.cmd.help, -- vim help links
            ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
          },
          highlights = {
            ["|%S-|"] = "@text.reference",
            ["@%S+"] = "@parameter",
            ["^%s*(Parameters:)"] = "@text.title",
            ["^%s*(Return:)"] = "@text.title",
            ["^%s*(See also:)"] = "@text.title",
            ["{%S-}"] = "@parameter",
          },
        },
        health = {
          checker = true, -- Disable if you don't want health checks to run
        },
        throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
        views = {
          oroshi_search = {
            view = "mini",
            format = { "{message}", hl_group = 'WinSeparator' },
            hl_group = "WinSeparator",
          }
        }, ---@see section on views
        -- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/routes.lua
        --
        routes = {
          -- Search info
          {
            filter = {
              event = "msg_show",
              kind = { "search_count" },
            },
            view = "oroshi_search",
            opts = {
              hl_group = "WinSeparator",
              format = {
                "{message}",
                hl_group = "WinSeparator",
              },
            }
          }

        }, --- @see section on routes
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
