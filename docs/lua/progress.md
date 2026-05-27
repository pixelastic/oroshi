## Execution order

### Act 1 — Lint
issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → start here, no blockers (parallel with issue-001)
issue-004 → needs issue-002 + issue-003
issue-005 → needs issue-004 (HITL: human must verify in Neovim)
issue-006 → needs issue-004 + issue-005

### Act 2 — Fix
issue-007 → start here, no blockers (can run in parallel with Act 1)
issue-008 → needs issue-007
issue-009 → needs issue-006 + issue-008

### Act 3 — Test
issue-010 → start here, no blockers (can run in parallel with Acts 1 & 2)
issue-011 → needs issue-010
issue-012 → needs issue-011

## Guidance

- **Language**: all scripts are ZSH unless otherwise noted. Use `setopt local_options errexit` in autoloaded functions, `set -e` in shebang scripts.
- **Local vars**: use `local var="$(cmd)"` + manual guard. Never split `local` from assignment.
- **Install scripts**: follow the pattern in `scripts/install/_languages/` — curl from GitHub releases to `~/local/bin/`, chmod +x.
- **Violation format**: `file▮code▮level▮line▮message` using Unicode `\u25ae` as separator. Same as `zshlint-custom`.
- **JSON output**: `lua-lint` outputs a JSON array. Parse the ▮-separated stream and convert with jq or a small ZSH loop, same as `zshlint`.
- **BATS tests**: co-located in `__tests__/` directories. Load helper from `config/term/bats/helper`. Follow patterns in `scripts/bin/zsh/zshlint/__tests__/`.
- **Spec files**: named `<module>_spec.lua`, co-located in `__tests__/` alongside the Lua source. mini.test syntax: `describe` / `it` / `MiniTest.expect`.
- **minit.lua location**: `config/vim/nvim/config/minit.lua`.
- **selene config location**: `config/vim/nvim/selene.toml` and `config/vim/nvim/vim.toml`.
- **lua-test-path**: mirrors `bats-test-path` at `scripts/bin/term/bats/bats-test-path`.
- **git-file-lint / git-file-test**: autoloaded functions at `config/term/zsh/functions/autoload/git/file/`. Extend by adding a Lua branch alongside the existing ZSH branch.
- **issue-005 is HITL**: after implementation, a human opens a Lua file in Neovim to verify diagnostics appear correctly before the issue is marked done.

---
## Log (append below when an issue is completed)
