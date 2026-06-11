## TLDR

Add an `is-js` autoload helper that identifies JS files by `.js` extension or node shebang.

## What to build

A new autoload function `is-js` in `tools/term/zsh/config/functions/autoload/term/zsh/` (or a dedicated `js/` sibling directory — follow the convention used by `is-bats` and `is-zsh`).

Identification logic:
- Symlinks and non-regular files → exit 1
- `.js` extension → exit 0
- Any other non-empty extension → exit 1
- No extension: read first line; `#!/usr/bin/env node` → exit 0, anything else → exit 1

## Behavioral Tests

**`.js` extension:**
- exits 0 for a `.js` file

**Other extensions:**
- exits 1 for a `.zsh` file
- exits 1 for a `.bats` file

**Extensionless files:**
- exits 0 for an extensionless file with `#!/usr/bin/env node` shebang on line 1
- exits 1 for an extensionless file with `#!/usr/bin/env zsh` shebang on line 1
- exits 1 for an extensionless file with no shebang

**Edge cases:**
- exits 1 for a symlink to a `.js` file
- exits 1 for a directory path

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `is-js` exists as an autoload function
- [ ] exits 0 for `.js` files
- [ ] exits 1 for `.zsh`, `.bats`, and other non-JS extensions
- [ ] exits 0 for extensionless files with `#!/usr/bin/env node` shebang
- [ ] exits 1 for extensionless files with other shebangs or no shebang
- [ ] exits 1 for symlinks and directories
- [ ] BATS test suite passes
