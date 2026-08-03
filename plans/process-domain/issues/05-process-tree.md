## TLDR

Add `process-tree` — colored tree display of process ancestry with `└──` connectors.

## What to build

Create `tools/term/zsh/config/functions/autoload/system/process/process-tree`.

The function takes a single PID argument, calls `process-tree-raw`, and formats the output as a tree:

```
name (PID)
└── parentName (parentPID)
    └── grandparentName (grandparentPID)
```

- Name displayed in `executable` color (yellow) via `colorize`
- PID displayed in `number` color (blue) via `colorize`
- First line (self) has no connector
- Each subsequent line gets `└──` with increasing indentation (4 spaces per level)
- Calls `colors-load-definitions` explicitly

Does NOT use `table` — builds the tree display directly.

## Behavioral Tests

File: `tools/term/zsh/config/functions/autoload/system/process/__tests__/process-tree.bats`

Tests mock `process-tree-raw` via `bats_mock` to return deterministic output and mock `colorize` + `colors-load-definitions` for predictable assertions.

**Tree formatting:**
- first line has no connector, shows "name (PID)"
- second line starts with "└──"
- third line starts with "    └──" (4-space indent)

**Color application:**
- colorize is called with executable color for name
- colorize is called with number color for PID

**Empty input:**
- returns 0 with no output when process-tree-raw returns 1

## Acceptance criteria

- [ ] Tree connectors render correctly with increasing indentation
- [ ] Name and PID are passed to `colorize` with correct color keys
- [ ] First line has no connector
- [ ] Handles missing PID gracefully
- [ ] All tests pass via `bats`
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes
