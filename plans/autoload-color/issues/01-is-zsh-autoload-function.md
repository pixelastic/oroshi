## TLDR

Create the `is-zsh-autoload-function` autoload helper that detects whether a path belongs to an autoloaded ZSH function.

## What to build

A new autoload function `is-zsh-autoload-function`, placed as a sibling of `is-zsh` in the `term/zsh` autoload subdirectory.

It takes a file path as its only argument. It sets `REPLY="1"` if both conditions hold:
- the path matches `*/functions/autoload/*`
- the file has no extension (`${path:e} == ""`)

Otherwise it sets `REPLY="0"`. No stdout output, no subshell — callers read `$REPLY` directly.

Write a bats test suite alongside it (prior art: `is-zsh.bats` in the same `__tests__` directory).

## Behavioral Tests

**When the file is inside `functions/autoload/` with no extension:**
- sets `REPLY="1"`

**When the file is inside `functions/autoload/` but has an extension:**
- sets `REPLY="0"` for a `.bats` file
- sets `REPLY="0"` for a `.zsh` file

**When the file is outside `functions/autoload/`:**
- sets `REPLY="0"` for a no-extension file elsewhere

**When the path is a directory:**
- sets `REPLY="0"` for a directory inside `functions/autoload/`

## Acceptance criteria

- [ ] `is-zsh-autoload-function` created in `term/zsh` autoload subdirectory
- [ ] Uses `setopt local_options err_return`
- [ ] Sets `REPLY="1"` or `REPLY="0"` — no stdout
- [ ] Bats test suite covers all four behavioral scenarios above
- [ ] `zsh-lint` passes on the new function
- [ ] `bats-lint` passes on the test file
