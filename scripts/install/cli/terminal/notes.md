Picking the right terminal is hard. I have been testing a few of them, but they
seem to all have drawbacks. I was on Termite for a long time, but could not
install it on Ubuntu 20.04, so I had to find another.

Here are my findings, documenting why I discarded some, to avoid wasting too
much time next time I have to switch.

## Termite

https://github.com/thestinger/termite

Termite needs a patched version of `vte` (whatever that is), to work. I could
make it work on 18.04 by downloading some files and putting them in `/usr/lib`,
but this does not work on 20.04: Termite just refuses to launch. Actually, even
gnome-terminal refuses to launch after that.

Having to manually install patched files for a library is a bad small anyway, so
I'd rather not use Termite until it's fully supported.

## Terminology

https://www.enlightenment.org/about-terminology.md

Terminology looks awesome. It has a very clean look and feel and all the little
details I like: clear caret, inline of media files, etc.

The main issue is that it depends on Enlightenment, a larger window manager, so
it does not play well with Gnome. For example, it does not inherit from the font
size defined in the OS, and intercepts xmodmap keybindings (so you have to
close/open Terminology every time you update the bindings).

Also, config files are saved as binary, and cannot be easily stored in a dotfile
repo.

Overall I found that it looked pretty good, but was a pain to configure.

## Kitty

https://sw.kovidgoyal.net/kitty/

This one looks very promising. It is geared toward people using their keyboard
a lot, which is what I do. It does have a lot of similar features than tmux (in
regard to splitting), but as I will be using tmux I don't need them that much.

It does have a very extensive support of fonts, allowing me to properly
configure which font I wanted to use. But because of the way it handles display
of characters, custom characters like the Octicons are displayed very small.
Each char is expected to be monospace, so the icons are scaled down to fit in
one cell, which makes most of the Nerd Font icons unusable.

## Alacritty

https://github.com/alacritty/alacritty

This boast being fast and ditching splits and tabs features. I like this.
