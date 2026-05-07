I wanted to be able to change the colors used by Claude Code colorscheme
(Monokai), but those are hardcoded and can't be tweaked.

So I thought I could just load the `dark-ansi` theme and override the ANSI code
(specific ANSI sequences allow you to do that) to my favored RGB colors.

I spent hours reverse-engineering the various ANSI code used for strings,
keywords, etc and then realized a major limitation of the `dark-ansi` theme: the
diff don't have colored background, which I find really helful.

So, all of that was for nothing, and I reverted to the default `dark` theme,
with its ugly Monokai theme and I hope I'll get used to it eventually.

As to not lose my research, below are the various sequences to run to swap the
ANSI default colors to my own before running Claude:

```zsh
# Overwrite ANSI colors for the ansi-dark theme
# Used by the syntax highlighter when using Write or Edit
printf "\e]4;8;rgb:68/68/68\e\\"  # Comments
printf "\e]4;10;rgb:31/82/ce\e\\" # Strings
printf "\e]4;11;rgb:d6/9e/2e\e\\" # Functions
printf "\e]4;12;rgb:31/82/ce\e\\" # Numbers
printf "\e]4;13;rgb:38/a1/69\e\\" # Keywords
printf "\e]4;14;rgb:f8/71/71\e\\" # Types

# Used when just displaying code in the interface
printf "\e]4;1;rgb:31/82/ce\e\\" # Strings
printf "\e]4;4;rgb:38/a1/69\e\\" # Keywords
printf "\e]4;6;rgb:f8/71/71\e\\" # Types

~/.oroshi/node_modules/.bin/claude "$@"

# Reverts all colors
printf "\e]104\e\\"

```
