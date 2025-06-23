-- zsh
F.ftset("*config/term/zsh/functions/autoload/*", "zsh")
F.ftplugin("zsh",
  function()
    F.imap('##', '${}<Left>', 'Create interpolated variable', { buffer = F.bufferId() })
  end
)
