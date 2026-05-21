## PRD

[zshlint-precommit/PRD.md](./PRD.md)

## What to build

New autoloaded function `term/zsh/is-zsh`. Takes a single file path as argument. Exits 0 if the file is a ZSH file, 1 otherwise. Detection rules applied in order:

1. Not a regular file (directory, symlink, etc.) → exit 1
2. Has a `.zsh` extension → exit 0
3. Path contains `functions/autoload/` and has no extension → exit 0
4. Has no extension and first line is exactly `#!/usr/bin/env zsh` → exit 0
5. Otherwise → exit 1

No environment variables or path overrides required. The `functions/autoload/` substring match works against any absolute path including temporary test directories.

## Acceptance criteria

- [ ] `is-zsh path/to/file.zsh` exits 0
- [ ] `is-zsh path/to/functions/autoload/git/file/my-func` (no extension) exits 0
- [ ] `is-zsh path/to/script` where first line is `#!/usr/bin/env zsh` exits 0
- [ ] `is-zsh path/to/script` where first line is `#!/usr/bin/env ruby` exits 1
- [ ] `is-zsh path/to/script` with no extension and no shebang exits 1
- [ ] `is-zsh path/to/functions/autoload/git/file/` (a directory) exits 1
- [ ] `is-zsh path/to/functions/autoload/misc/__tests__/slugify.bats` exits 1
- [ ] Bats test file exists at `term/zsh/__tests__/is-zsh.bats` covering all cases above

## Blocked by

None — can start immediately.
