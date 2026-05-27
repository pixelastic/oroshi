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
- **selene config location**: `config/_languages/lua/selene/selene.toml` and `config/_languages/lua/selene/vim.yml` (YAML format, not TOML — selene 0.31 dropped TOML std format).
- **lua-test-path**: mirrors `bats-test-path` at `scripts/bin/term/bats/bats-test-path`.
- **git-file-lint / git-file-test**: autoloaded functions at `config/term/zsh/functions/autoload/git/file/`. Extend by adding a Lua branch alongside the existing ZSH branch.
- **issue-005 is HITL**: after implementation, a human opens a Lua file in Neovim to verify diagnostics appear correctly before the issue is marked done.

---
## Log (append below when an issue is completed)

## Session 2026-05-27 — 0002: lua-lint-selene
- Completed: `lua-lint-selene` script at `scripts/bin/vim/lua/` + 3 BATS tests
- Tests added: exits 0 with no output for clean file; outputs violation line in file▮code▮level▮line▮message format; exits 1 when violation found
- Discovered: selene `--config` accepts absolute path and finds companion `vim.yml` from same dir; `start_line` is 0-indexed so `+1` conversion is correct
- Fixed: none
- Skipped feedback: all review findings were false positives — `local` at script scope (known ZSH false positive, same as lua-test-path), "broken script" (reviewer received garbled diff), `bats_run_script` (project uses `run zsh`), start_line off-by-one (verified correct)
- Next: issue-003 (lua-lint-custom) — no blockers, can run in parallel

## Session 2026-05-27 — 0010: lua-test-path
- Completed: `lua-test-path` script + 5 BATS tests at `scripts/bin/vim/lua/`
- Tests added: returns existing spec, exits 1 for missing spec file, resolves source to spec, exits 1 when no spec, exits 1 with no args
- Discovered: reviewer flagged `local`/`return` at script top-level as invalid ZSH — verified false positive, both work fine in ZSH scripts (same as bats-test-path reference)
- Fixed: added missing "no arguments" test case (present in reference bats-test-path.bats)
- Skipped feedback: `local` at script scope / `return` vs `exit` — not violations in ZSH
- Next: issue-011 (lua-test + mini.test runner) — depends on this issue

## Session 2026-05-27 — 0001: selene-install
- Completed: install script at `scripts/install/_languages/lua/selene`; `selene.toml` + `vim.yml` at `config/_languages/lua/selene/`
- Tests added: none — user deleted BATS test file; install verified manually (selene 0.31.0 works)
- Discovered: selene 0.31 "light" build uses YAML for std library files (`vim.yml`), not TOML (`vim.toml`); `std = "lua54+vim"` format invalid — use `std = "vim"` with a `vim.yml` companion; config location moved to `config/_languages/lua/` (user decision)
- Fixed: removed unused `INSTALL_PATH` variable; added Usage block to install script header
- Skipped feedback: `local` at script scope (false positive), `wget` vs `curl` (user's script), `extract` helper (user's script), config location discrepancy (user's decision), mv-to-bin vs symlink (user's decision)
