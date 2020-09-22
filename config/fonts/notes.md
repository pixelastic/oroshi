## Installing fonts

Put the fonts in `~/.fonts`, then run `fc-cache -f -v`.

To get the list of all fonts, run 

```
fc-list -f '%{family}\n' | awk '!x[$0]++' | sort
```

## Icons

https://github.com/ryanoasis/nerd-fonts contains a lot of dev-friendly symbols.

It is not recommended to use a patched font, but instead rely on the font
fallback system of the terminal. Using the fallback it's easy to switch the main
font while keeping the symbols.

Note that Kitty will always prefer monospaces fonts by default, but it tends to
draw small icons for symbol fonts. It is then advised to use a non-mono symbol
font in Kitty.

The safest way is to add the font to ~/.fonts, making sure we don't have any
Mono version that could conflict. Then, defining some `symbol_map` to explicitly
tell Kitty to look for symbols in that font.
