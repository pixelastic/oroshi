## Powerline

The `PowerlineSymbols.ttf` is a magic file that we can drop in the `~/.fonts`
directory to add the powerline needed missing glyphs.

This is a file I patched a few years ago and can't retrieve the commands I used
to do it. I haven't been able to regenerate it lately, but hopefully I still
had it and simply dropping it in `~/.fonts` makes powerline work again, for any
font.

There exists a repository of common mono fonts, patched to include the missing
glyphs. But `Deja Vu Sans Mono` is not listed in it. Anyway, just dropping the
file does work.

## Octicons

The font I'm usually using for coding is `Deja Vu Sans Mono`. Included is
a version merged with the `Octicons` font, including glyphs from GitHub.

According to `awesome-terminal-fonts` I should be able to define a fallback
chain of fonts to use in case of missing glyphs, but can't manage to make it
work. Instead I patched the original `Deja Vu Sans Mono` font with the
`Octicons` font.


## Tools

In this repository you'll find:

- The original `Deja Vu Sans Mono` font
- The `Octicons` font
- The python `font-merge-python` script
- A wrapper (`$ font-merge font1 font2`) to merge two fonts`


## Sources

- https://octicons.github.com/
- https://github.com/powerline/fonts
- https://github.com/gabrielelana/awesome-terminal-fonts/tree/patching-strategy
- http://dejavu-fonts.org/wiki/Download

