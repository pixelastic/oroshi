## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Fix the bugs in `colorize` and add a `--zsh` flag.

Currently `colorize` has several issues: `echo` appends a newline that prevents direct concatenation, `%G{bg}` is wrong (should be `%K{bg}`), ANSI sequences are missing the `\e` escape character, and the zsh suffix is `%f` (does not reset the background). Additionally, zsh mode is toggled via `OROSHI_IS_PROMPT=1` (implicit env var) rather than an explicit flag.

After this fix:
- `colorize text fg bg` → correct ANSI with `\e[38;5;...m`, terminated by `\e[0m`
- `colorize text fg bg --zsh` → zsh prompt format `%F{fg}%K{bg}text%f%k`
- Multiple direct calls concatenate without stray newlines
- `OROSHI_IS_PROMPT` remains supported temporarily for backward compatibility (removed in issue-005)

## Acceptance criteria

- [ ] `colorize text 87 100` produces `\e[38;5;87m\e[48;5;100mtext\e[0m` (correct ANSI)
- [ ] `colorize text 87 100 --zsh` produces `%F{87}%K{100}text%f%k`
- [ ] `colorize text 87` (no bg) produces output with no `%K{` and no `\e[48;`
- [ ] `colorize text 87 100 --zsh` contains no `\e[` sequence
- [ ] `colorize text 87 100` contains no `%K{`
- [ ] Two consecutive direct `colorize` calls → output concatenates without `\n` between them
- [ ] Bats tests pass: `config/term/zsh/functions/autoload/misc/__tests__/colorize.bats`

## Blocked by

None — can start immediately.
