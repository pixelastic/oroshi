## Guidance

### Goal

Create a `python-writer` skill and unify the lint/fix pattern across ZSH and Python to match the JavaScript convention (`yarn lint:fix`).

### Testing commands

- ZSH scripts: `bats <filepath>`
- ZSH lint: `zsh-lint <filepath>`
- Bats lint: `bats-lint <filepath>`
- Python lint: `python-lint <filepath>`
- Python tests: `python-test <filepath>` (once issue 03 is done)

### File locations (relative to repo root)

- Python bin scripts: `scripts/bin/python/`
- Python bats tests: `scripts/bin/python/__tests__/`
- ZSH lint: `scripts/bin/zsh/zsh-lint/zsh-lint`
- ZSH lint tests: `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats`
- Language install scripts: `tools/_languages/python/<tool>/install`
- Skills: `tools/ai/claude/config/skills/`
- CLAUDE.md: `tools/ai/claude/config/CLAUDE.md`
- kitty config root: `tools/term/kitty/config/`

### Conventions

- Bats tests use `bats_run_zsh "script-name args"` — never call scripts directly
- Bats tests use `bats_mock` to stub collaborators, not filesystem state
- All bats test vars go inside `setup()`, not at file top level
- Python test files: `test_<module>.py` in `__tests__/` sibling directories
- `conftest.py` goes at project root (same level as `pyproject.toml`), not inside `__tests__/`
- Install scripts mirror the ruff pattern: one script per tool, uses pipx when available

### Prior art

- `scripts/bin/python/python-lint` — existing python-lint script (uses ruff check)
- `scripts/bin/python/python-fix` — existing python-fix script (uses ruff format, ruff check --fix commented out)
- `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint.bats` — prior art for bats style on zsh-lint
- `tools/_languages/python/ruff/install` — prior art for language install script pattern
- `tools/ai/claude/config/skills/zsh-writer/SKILL.md` — structural model for python-writer

### Key constraint

Issues 01, 02, and 03 are independent and can be implemented in any order or in parallel. Issue 04 requires both 01 and 03. Issue 05 requires 02.

## Discoveries

<!-- Agents append findings here after each issue, format: -->
<!-- ### Issue XX — short title -->
<!-- - finding -->
