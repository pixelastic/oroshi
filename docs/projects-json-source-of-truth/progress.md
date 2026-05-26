## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-002
issue-004 → needs issue-002
issue-005 → needs issue-002
issue-006 → needs issue-002

## Guidance

- **Worktree**: all work happens in the `projects-json-source-of-truth` worktree at `~/local/www/worktrees/oroshi--projects-json-source-of-truth/`
- **Testing ZSH**: `bats <filepath>` — tests live in `config/term/zsh/theming/src/__tests__/`
- **Linting ZSH**: `zshlint <filepath>`
- **Build script location**: `config/term/zsh/theming/src/projects-build`
- **Source file**: `config/term/zsh/theming/src/projects.json`
- **Dist files**: `config/term/zsh/theming/dist/projects.json` and `config/term/zsh/theming/dist/projects.zsh`
- **dist/ is gitignored** — do not commit dist files; the pre-commit hook (issue-005) handles staging them
- **Icons contain Nerd Font private-use-area codepoints** — always use `Edit` (never `Write`) when modifying any file that contains icon characters; `Write` silently corrupts them
- **Old pipeline stays**: `src/projects-list.zsh`, `src/env-generate-projects`, and `env/projects.*` are NOT touched in this PRD — they run in parallel until the ZSH functions PRD removes them
- **Color palette**: resolved by sourcing `env/colors.zsh`; no `dist/colors.json` is produced here
- **backgroundInactive derivation**: strip from first underscore onward (`GREEN_8` → `GREEN`, `GREEN` → `GREEN`), prepend `DARK_` → look up in colors palette

---
## Log (append below when an issue is completed)
