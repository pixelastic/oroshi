# rg (ripgrep)
# rg accepts a config file, but doesn't specifically look in a pre-defined
# place, like ~/.rgrc, so we manually tell it where to look
#
# https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#configuration-file
export RIPGREP_CONFIG_PATH=$OROSHI_ROOT/tools/cli/rg/config/dist/rgrc.conf
