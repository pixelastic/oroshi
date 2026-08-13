## TLDR

Flatten `scripts/bin/` by removing subdirectories, deleting dead artifacts, and moving remaining scripts to root.

## What to build

Move `solkan` symlink from `scripts/bin/misc/solkan` to `scripts/bin/solkan` (update symlink target to `../../node_modules/.bin/solkan`).

Move `spotify-dbus` from `scripts/bin/spotify/spotify-dbus` to `scripts/bin/spotify-dbus`.

Delete dead artifacts:
- `scripts/bin/html/prettier` symlink (unused, prettier-fix resolves its own binary)
- `scripts/bin/docker/__README.md` (redundant with inline function headers)
- `scripts/bin/text/__tests__/` (5 orphan test files for functions deleted in commit 26792da)

Delete now-empty directories after moves and deletions:
- `scripts/bin/html/`
- `scripts/bin/docker/`
- `scripts/bin/text/`
- `scripts/bin/misc/` (after solkan moved out)
- `scripts/bin/spotify/` (after spotify-dbus moved out)
- `scripts/bin/http/` (scripts migrated in issue 28)
- `scripts/bin/ai/` (tests moved in issue 32)

Note: `scripts/bin/http/` and `scripts/bin/ai/` may still contain files at this point if issues 28 and 32 haven't run yet. Only delete directories that are actually empty.

## Scaffolding Tests

- `solkan` is callable by name after move
- `spotify-dbus` is callable by name after move
- Deleted files no longer exist on disk

## Acceptance criteria

- [ ] `solkan` symlink at `scripts/bin/solkan`, points to correct target
- [ ] `spotify-dbus` at `scripts/bin/spotify-dbus`
- [ ] `html/prettier` symlink deleted
- [ ] `docker/__README.md` deleted
- [ ] `text/__tests__/` (5 files) deleted
- [ ] All empty subdirectories removed
- [ ] Existing tests still pass (bin-zsh, bats fixtures)
