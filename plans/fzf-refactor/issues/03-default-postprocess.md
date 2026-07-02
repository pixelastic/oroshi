## TLDR

Move the standard `fzf-postprocess` implementation into `init.zsh` as a default, eliminating boilerplate across 10 FZF scripts.

## What to build

Add a default `fzf-postprocess` to `init.zsh` (next to the existing default `fzf-main`). Scripts that use the standard pattern can delete their implementation entirely. Scripts with custom behavior keep theirs and it overrides the default.

**Default implementation (in init.zsh):**
```zsh
fzf-postprocess() {
  local input="$(\cat)"
  [[ "$input" == "" ]] && return 0
  local line
  for line in ${(f)input}; do
    print -- "${line%%▮*}"
  done
}
```

**Scripts to update (delete their fzf-postprocess):**
- ctrl-o, ctrl-p, ctrl-shift-o, ctrl-shift-p
- fzf-apt-packages, fzf-bats-test, fzf-docker-images
- fzf-git-files-dirty-stageable, fzf-plans, ctrl-r

**Scripts to leave untouched (custom behavior):**
- ctrl-b — prints full input without splitting on ▮
- ctrl-g, ctrl-shift-g — delegate to `fzf-regexp-postprocess`

## Acceptance criteria

- [ ] Default `fzf-postprocess` defined in `init.zsh`
- [ ] 10 scripts no longer define their own `fzf-postprocess`
- [ ] `ctrl-b`, `ctrl-g`, `ctrl-shift-g` postprocess unchanged
- [ ] All existing tests pass
