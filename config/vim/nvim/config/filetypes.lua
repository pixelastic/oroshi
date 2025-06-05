local ftplugin = F.ftplugin
local ftdetect = F.ftdetect
local ftset = F.ftset
local autocmd = F.autocmd

-- help
ftplugin(
  {'help', 'man'},
  function()
    -- Expand to full height
    local function takeAllHeight()
      vim.cmd('resize +999')
    end
    takeAllHeight()

    -- Expand again on each resize
    autocmd('VimResized', takeAllHeight, { buffer = vim.api.nvim_get_current_buf() })
  end
)

-- xkb
ftdetect(
  "*config/keybindings/xkb/xkbmaprc.conf", 
  function()
    vim.bo.filetype      = "c"
    vim.bo.syntax        = "xkb"
    vim.bo.commentstring = "// %s"
  end
)


-- zsh
ftset("*config/term/zsh/functions/autoload/*", "zsh")
