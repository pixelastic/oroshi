#!/usr/bin/env zsh
# Watch changes with `dconf watch /`, then edit keybindings in `ccsm` to see
# what needs to be updated.

# Super-T is terminator
dconf write /org/compiz/integrated/command-1 "'terminator'"
dconf write /org/compiz/integrated/run-command-1 "['<Super>t']"

# Ctrl-Super-C is Chromium pro
dconf write /org/compiz/integrated/command-2 "'chromium-browser --disable-gpu --profile-directory=\"Profile 2\"'"
dconf write /org/compiz/integrated/run-command-2 "['<Control><Super>c']"

# Ctrl-Super-Alt-C is Chromium perso
dconf write /org/compiz/integrated/command-3 "'chromium-browser --disable-gpu --profile-directory=\"Profile 1\"'"
dconf write /org/compiz/integrated/run-command-3 "['<Control><Alt><Super>c']"

# Ctrl-Super-K is keepass
dconf write /org/compiz/integrated/command-4 "'keepassx ~/Dropbox/tim/config/keys.kdb'"
dconf write /org/compiz/integrated/run-command-4 "['<Control><Super>K']"

# Super-Z is Zeal
dconf write /org/compiz/integrated/command-5 "'zeal'"
dconf write /org/compiz/integrated/run-command-5 "['<Super>Z']"

# Ctrl-Super-T is Pomodoro
dconf write /org/compiz/integrated/command-6 "'tomate-gtk'"
dconf write /org/compiz/integrated/run-command-6 "['<Control><Super>T']"

# Super-H is Hipchat
dconf write /org/compiz/integrated/command-10 "'hipchat'"
dconf write /org/compiz/integrated/run-command-10 "['<Super>H']"


