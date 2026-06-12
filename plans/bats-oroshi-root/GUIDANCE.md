## Guidance

### Context

This PRD refactors the BATS helper system to formally enforce three principles defined in `tools/term/bats/GLOSSARY.md`:
- **Worktree-aware** — binaries resolved during a test come from the oroshi root that launched `bats`
- **Deep Mocking** — mocked functions stay mocked at any call depth, including new zsh processes
- **Root Override** — `OROSHI_ROOT` is overrideable for data/config testing without affecting binary resolution

### Files

- Helper under modification: `tools/term/bats/config/helper`
- Test suite to create: `tools/term/bats/config/__tests__/helper.bats`
- Glossary: `tools/term/bats/GLOSSARY.md`
- `zshenv.zsh`: `tools/term/zsh/config/zshenv.zsh`
- Bats-lint rules: `scripts/bin/term/bats/bats-lint/__rules/`

### Commands

- Run the helper test suite: `bats tools/term/bats/config/__tests__/helper.bats`
- Run the full test suite: `bats --recursive .`
- Lint a zsh file: `zsh-lint <filepath>`
- Lint a bats file: `bats-lint <filepath>`

### Conventions

- All test variables go inside `setup()`, not at file top level
- Use `bats_run_script` (not `bats_run_zsh`) for scripts that are NOT autoloaded functions
- Mock definitions: define the function in the test, then call `bats_mock fn_name`
- The `foo → bar → baz` fixture is the canonical test scaffold for issues 03–05: `foo` calls `bar`, `bar` calls `baz`, `baz` is the observable leaf
- Use `$OROSHI_ROOT` for all oroshi paths — `$ZSH_CONFIG_PATH` and `$OROSHI_ZSH_AUTOLOAD` are removed in issues 01–02

### Prior art

- Worktree test patterns: `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/`
- Env var propagation into subprocesses: `tools/term/zsh/config/__tests__/zshenv.bats`
- Mock usage examples: `scripts/bin/term/bats/bats-lint/__tests__/bats-lint.bats`

## Discoveries

_Append findings here after each issue is completed._

### Issue 04 — Deep Mocking

- Deep mocking was already fully implemented: `bats_mock` exports `MOCK_OVERRIDE`, and `zshenv-guest.zsh` sources it at the end of every zsh startup — making mocks visible in all spawned processes automatically.
- `bats_run_zsh` had a redundant explicit `source mock.zsh` prefix; it was removed — `MOCK_OVERRIDE` is the single mechanism.
- In zsh, a defined function takes precedence over a same-named PATH command — no wrapper scripts needed for mock priority.

### Issue 05 — Root Override

- Root override was already correctly implemented: `bats_mock_oroshi_root` writes `export OROSHI_ROOT=…` to mock.zsh (sourced after PATH setup in zshenv-guest.zsh), so PATH stays anchored to the launcher's root while `$OROSHI_ROOT` is overridden.
- The orthogonality guarantee holds because `oroshi-reload-path` is only called once (before mock sourcing) with the real root; the mock never calls it.
- A single "composable" test proves both mechanisms simultaneously: mock baz + override root in the same setup, then assert both the overridden OROSHI_ROOT and the unaffected binary path.
