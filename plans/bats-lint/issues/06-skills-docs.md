## TLDR

Update `zsh-writer/SKILL.md` and `CLAUDE.md` so the agent knows to run `bats-lint` on test files.

## What to build

Two documentation updates:

**`zsh-writer/SKILL.md`:** In the lint step (Step 4), after the instruction to run `zshlint` on the `.zsh` file, add an instruction to also run `bats-lint` on the corresponding `.bats` test file and fix every violation.

**`CLAUDE.md`:** In the Commands section, add:
```
- **Linting bats:** Run `bats-lint <filepath>`
```

## Acceptance criteria

- [ ] `zsh-writer/SKILL.md` Step 4 instructs to run `bats-lint` on the test file
- [ ] `CLAUDE.md` Commands section includes `bats-lint <filepath>`
- [ ] No other content in either file is modified
