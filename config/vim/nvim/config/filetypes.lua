local ftplugin = F.ftplugin
local ftdetect = F.ftdetect
local ftset = F.ftset
local autocmd = F.autocmd
local bufferId = F.bufferId
local imap = F.imap
local nmap = F.nmap

-- help
ftplugin(
  {'help', 'man'},
  function()
    -- Expand to full height
    local function takeAllHeight()
      vim.cmd('resize +999')
    end

    -- Expand again on each resize
    autocmd({'VimResized', 'BufEnter' }, takeAllHeight, { buffer = bufferId() })
  end
)

-- noice
ftplugin('noice', function()
  nmap('<CR>', '', 'Unmap <CR>', { buffer = bufferId() }) -- Disable <CR>, was triggering issues
end)

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
ftplugin("zsh",
  function()
    imap('##', '${}<Left>', 'Create interpolated variable', { buffer = bufferId() })
  end
)
