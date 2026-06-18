## TLDR

Apply the prompt convention: context-badge for file/directory sources, icon+label for non-file sources. Fix `fzf-git-files-dirty-stageable` prompt.

## What to build

**Prompt rule (to be documented in GLOSSARY.md via a /glossary session):**
- Source lists files or directories → **context-badge** (+ simplified path if scope = cwd)
- Source lists something else (test names, packages, commands) → **icon + label**

**Fix `fzf-git-files-dirty-stageable` prompt:**
- Current: custom icon `$ICONS[git-file-dirty]` with colored background
- Target: context-badge from `fzf-options-prompt-directory` using git root
- The search is git-root scoped, so: context-badge only, no path suffix

**Verify all other scripts match the convention:**
- ctrl-p, ctrl-o: files/dirs, git root → context-badge only ✓
- ctrl-shift-p, ctrl-shift-o: files/dirs, cwd → context-badge + path ✓
- fzf-plans: dirs, git root → context-badge ✓
- fzf-bats-test: test names → icon + label ✓
- ctrl-r, ctrl-b, fzf-apt-packages, fzf-docker-images: global → no prompt ✓

## Acceptance criteria

- [ ] `fzf-git-files-dirty-stageable` uses `fzf-options-prompt-directory` with git root
- [ ] All FZF scripts follow the prompt convention
- [ ] `zsh-lint` passes on all modified files
