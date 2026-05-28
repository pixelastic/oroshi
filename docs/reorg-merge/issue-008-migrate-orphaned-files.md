## PRD

[Merge main into reorg](PRD.md)

## What to do

After the merge, 22 files added by main land at old `config/` paths that reorg had already cleared. Move them to the correct `tools/` locations in one commit.

## Files to migrate

### `config/ai/claude/` → `tools/ai/claude/config/`

```bash
git mv config/ai/claude/__tests__/statusline.bats \
       tools/ai/claude/config/__tests__/statusline.bats

git mv config/ai/claude/hooks/__docs/GLOSSARY.md \
       tools/ai/claude/config/hooks/__docs/GLOSSARY.md

git mv config/ai/claude/hooks/__tests__/preToolUse-Bash-rtk.bats \
       tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-rtk.bats

git mv config/ai/claude/hooks/__tests__/preToolUse-Bash-solkan.bats \
       tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-solkan.bats

git mv config/ai/claude/hooks/__tests__/preToolUse-Bash.bats \
       tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats

git mv config/ai/claude/hooks/__tests__/stop.bats \
       tools/ai/claude/config/hooks/__tests__/stop.bats

git mv config/ai/claude/hooks/preToolUse-Bash-rtk \
       tools/ai/claude/config/hooks/preToolUse-Bash-rtk

git mv config/ai/claude/hooks/preToolUse-Bash-solkan \
       tools/ai/claude/config/hooks/preToolUse-Bash-solkan
```

### `config/term/zsh/` → `tools/term/zsh/config/`

```bash
git mv config/term/zsh/functions/autoload/fzf/claude/sessions/__tests__/fzf-claude-sessions-preview.bats \
       tools/term/zsh/config/functions/autoload/fzf/claude/sessions/__tests__/fzf-claude-sessions-preview.bats

git mv config/term/zsh/functions/autoload/fzf/claude/sessions/__tests__/fzf-claude-sessions-source-no-query.bats \
       tools/term/zsh/config/functions/autoload/fzf/claude/sessions/__tests__/fzf-claude-sessions-source-no-query.bats

git mv config/term/zsh/functions/autoload/fzf/fs/shared/__tests__/fzf-fs-shared-preview-header.bats \
       tools/term/zsh/config/functions/autoload/fzf/fs/shared/__tests__/fzf-fs-shared-preview-header.bats

git mv config/term/zsh/functions/autoload/fzf/helpers/__tests__/fzf-prompt-directory.bats \
       tools/term/zsh/config/functions/autoload/fzf/helpers/__tests__/fzf-prompt-directory.bats

git mv config/term/zsh/functions/autoload/fzf/projects/__tests__/fzf-projects-source.bats \
       tools/term/zsh/config/functions/autoload/fzf/projects/__tests__/fzf-projects-source.bats

git mv config/term/zsh/functions/autoload/git/file/__tests__/git-file-edit.bats \
       tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-edit.bats

git mv config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-name.bats \
       tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-name.bats

git mv config/term/zsh/functions/autoload/git/worktree/git-worktree-name \
       tools/term/zsh/config/functions/autoload/git/worktree/git-worktree-name

git mv config/term/zsh/theming/dist/projects.json \
       tools/term/zsh/config/theming/dist/projects.json

git mv config/term/zsh/theming/dist/projects.zsh \
       tools/term/zsh/config/theming/dist/projects.zsh

git mv config/term/zsh/theming/src/__tests__/projects-build.bats \
       tools/term/zsh/config/theming/src/__tests__/projects-build.bats

git mv config/term/zsh/theming/src/projects-build \
       tools/term/zsh/config/theming/src/projects-build

git mv config/term/zsh/theming/src/projects.json \
       tools/term/zsh/config/theming/src/projects.json
```

After all moves, verify the `config/` dirs are empty again:
```bash
find config/ai/claude config/term/zsh -type f 2>/dev/null
# Should return nothing
```

Then check the moved bats files for any hardcoded `config/` paths that need updating to `tools/`:
```bash
grep -r "~/.oroshi/config/" tools/ai/claude/config/hooks/__tests__/
grep -r "~/.oroshi/config/" tools/term/zsh/config/theming/
```

Update any found references, then commit.

## Acceptance criteria

- [ ] No files remain under `config/ai/claude/` or `config/term/zsh/`
- [ ] All 22 files present at their `tools/` paths
- [ ] No `~/.oroshi/config/` references in the migrated bats files (use `tools/` or `$OROSHI_ROOT/tools/`)
- [ ] `git status` clean after commit

## Blocked by

issue-007
