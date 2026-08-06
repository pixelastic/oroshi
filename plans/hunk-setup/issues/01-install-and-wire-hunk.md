## TLDR

Install hunkdiff, deploy its config, and wire it into the git-file toolchain as `vfw`.

## What to build

End-to-end: after this issue, running `vfw` in any git repo opens Hunk in watch mode showing a live split diff of all tracked dirty files.

1. Add `hunkdiff` to `package.json` dependencies
2. Create `tools/git/hunk/config/config.toml` with: `mode = "split"`, `watch = true`, `line_numbers = true`, `transparent_background = true`, `exclude_untracked = true`
3. Create `tools/git/hunk/deploy` — symlinks config.toml to `~/.config/hunk/config.toml`
4. Create `tools/term/zsh/config/functions/autoload/git/file/git-file-watch` — launches `hunk diff --watch` from the git root
5. Add `alias vfw='git-file-watch'` to `tools/term/zsh/config/aliases/git/file.zsh`

## Acceptance criteria

- [ ] `hunkdiff` appears in package.json dependencies
- [ ] `yarn install` succeeds and `hunk` binary is available
- [ ] `tools/git/hunk/deploy` creates symlink at `~/.config/hunk/config.toml`
- [ ] Running `vfw` in a repo with dirty tracked files opens Hunk in split watch mode
- [ ] Untracked files are excluded from the diff view
