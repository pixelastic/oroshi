## TLDR

Replace hardcoded extension skips in `git-file-edit` with a filetype-group allowlist.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/file/git-file-edit`:

1. Call `filetypes-load-definitions` once before the loop
2. Inside the loop, replace the `yarn.lock` and `*.woff2` skip lines with:
   - Call `filetypes-group --reply "$filePath"` to get the group
   - Check against an allowlist `(text script config)`
   - Files with empty group (unknown extension) are accepted
   - Skip files whose group is not in the allowlist
3. Keep the path-based skips: `plans/*/state.json` and `plans/*/scaffold/*`
4. The `fileName` local variable can be removed if no longer needed

Mock `filetypes-group` in tests — it's the immediate collaborator.

## Behavioral Tests

Prior art: `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-edit.bats`

**accepts editable files**
- Modified `.js`, `.zsh`, `.txt` files are passed to nvim

**rejects binary files**
- Modified `.mp3` and `.woff2` files are not passed to nvim

**accepts files with unknown extensions**
- Modified file with an unregistered extension (e.g. `.xyz`) is passed to nvim

**still skips plan files**
- `plans/*/state.json` and `plans/*/scaffold/*` are not passed to nvim

## Acceptance criteria

- [ ] `.mp3`, `.woff2`, and other binary-group files are skipped
- [ ] `.js`, `.zsh`, `.txt` and other text/script/config files are opened
- [ ] Files with unknown extensions are opened
- [ ] `plans/*/state.json` and `plans/*/scaffold/*` still skipped
- [ ] No subprocess fork per file (uses `--reply`)
- [ ] Tests pass: `bats tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-edit.bats`
