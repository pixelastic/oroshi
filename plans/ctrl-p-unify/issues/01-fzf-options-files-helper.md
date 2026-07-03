## TLDR

Create the shared `fzf-options-files` lib that encapsulates all fzf options for file-search scripts.

## What to build

Create a new lib file `scripts/bin/fzf/__lib/fzf-options-files.zsh`.

The file self-sources `fzf-options-base.zsh` and `fzf-options-prompt-directory.zsh` at its top (same pattern as `fzf-source-files.zsh` self-sourcing `fzf-colorize-path.zsh`).

It exposes a single function `fzf-options-files(scriptName, searchPath)` that emits all fzf options for file-search scripts:
- delegates to `fzf-options-base` for shared base options
- calls `colors-load-definitions` before referencing `$COLORS[file]`
- emits `--with-nth=2`, `--scheme=path`, `--tiebreak=pathname,chunk`
- emits `--preview` using `scriptName`
- emits `--prompt` using `fzf-options-prompt-directory` with `searchPath`
- emits `--color=query`, `--color=info`, `--color=separator` using `$COLORS[file]`

## Acceptance criteria

- [ ] `fzf-options-files.zsh` exists in `scripts/bin/fzf/__lib/`
- [ ] File self-sources `fzf-options-base.zsh` and `fzf-options-prompt-directory.zsh`
- [ ] `fzf-options-files` function accepts `scriptName` and `searchPath` args
- [ ] Output includes all options listed above
- [ ] `zsh-lint` passes on the new file
