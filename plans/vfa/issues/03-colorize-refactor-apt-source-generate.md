## TLDR

Replace raw ANSI escape codes in `fzf-packages-apt-source-generate` with `colorize` calls and migrate to `$COLORS[package-installed]`.

## What to build

`fzf-packages-apt-source-generate` is the only file in the fzf subsystem that builds color
output by embedding raw ANSI escape sequences (`\e[38;5;Nm...\e[00m`) rather than using
`colorize`. Refactor the colored output to use `colorize`, matching the pattern used by
every other file in the subsystem. Replace `$COLOR_ALIAS_PACKAGE_INSTALLED` with
`$COLORS[package-installed]`.

Add `colors-load-definitions` near the top of the file.

The visible output (installed packages highlighted in the package-installed color) must be
identical before and after.

## Acceptance criteria

- [ ] No raw ANSI escape sequences remain in the file
- [ ] `$COLOR_ALIAS_PACKAGE_INSTALLED` is replaced with `$COLORS[package-installed]`
- [ ] `colors-load-definitions` is called before any `$COLORS[...]` reference
- [ ] Installed packages still appear visually distinct from uninstalled ones in the apt picker
- [ ] `zsh-lint` passes on the file
