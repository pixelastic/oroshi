#!/usr/bin/env zsh
# Install GNOME extensions to improve the default Gnome UI

# pipx is required to install dependencies
if ! command -v pipx >/dev/null; then
  echo "You need to install pipx first"
  exit 1
fi

# Installing gext, to simplify installing Gnome extensions
if ! command -v gext >/dev/null; then
  pipx install gnome-extensions-cli
fi

# Installing extensions
gext install advanced-alt-tab@G-dH.github.com        # AATWS (Advanced Alt-Tab Window Switcher)
gext install just-perfection-desktop@just-perfection # Just Perfection
gext install sp-tray@sp-tray.esenliyim.github.com    # spotify-tray
gext install unite@hardpixel.eu                      # Unite
gext install wsmatrix@martin.zurowietz.de            # Workspace Matrix
