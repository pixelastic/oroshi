# | Name      | Output                 | Modifier          | Mnemonic           |
# | --------- | ---------------------- | ----------------- | ------------------ |
# | Absolute  | `/tmp/subdir/file.zsh` | `${filepath:a}`   | `a`bsolute         |
# | Basename  | `file.zsh`             | `${filepath:t}`   | `t`ail             |
# | Filename  | `file`                 | `${filepath:t:r}` | `t`ail `r`est      |
# | Extension | `zsh`                  | `${filepath:e}`   | `e`xtension        |
# | Dirpath   | `/tmp/subdir`          | `${filepath:a:h}` | `a`bsolute `h` ead |
#
# - `t`ail is everything **after** the last `/`
# - `h`ead is everything **before** the last `/`
# - `e`xtension is everything **after** the last `.`
# - `r`est is everything **before** the last `.`

# ## Other goodies

# - `${~filepath}` will expand `~` to their full path, while
#   `${filepath/#$HOME/~}` will use `~` instead of home path
# - `:c`ommand gives you the executable path of a command (a bit like `which`)
# - `:q` for quoting, `:U` for unquoting, `:x` for quoting individual words
# - `:l` for lowercase, `:u` for uppercase
# - `:2:10` takes a substring from `2` to `10`
# - Those modifiers can be applied directly to glob patterns
#   (`src/**/*.zsh(:t:r)`)

