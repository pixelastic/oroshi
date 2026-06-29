## TLDR

Update the three `dist/*.zsh` build scripts to prepend `# zsh-lint disable-file=commandTooLong` as the first output line.

## What to build

In `projects-build`, `colors-build`, and `filetypes-build`, modify the `generateDistZsh()` function (or equivalent output block) to emit `# zsh-lint disable-file=commandTooLong` before the `typeset -gA` declaration. This makes all three generated `dist/*.zsh` files unconditionally exempt from `commandTooLong`, regardless of future data growth.

No tests are written for this slice — the generated file is the artifact.

Verify manually by running `projects-build` and confirming `dist/projects.zsh` starts with the comment and `zsh-lint dist/projects.zsh` exits 0.

## Acceptance criteria

- [ ] `dist/projects.zsh` starts with `# zsh-lint disable-file=commandTooLong` after running `projects-build`
- [ ] `dist/colors.zsh` starts with `# zsh-lint disable-file=commandTooLong` after running `colors-build`
- [ ] `dist/filetypes.zsh` starts with `# zsh-lint disable-file=commandTooLong` after running `filetypes-build`
- [ ] `zsh-lint dist/projects.zsh` exits 0
- [ ] `zsh-lint dist/colors.zsh` exits 0
- [ ] `zsh-lint dist/filetypes.zsh` exits 0
