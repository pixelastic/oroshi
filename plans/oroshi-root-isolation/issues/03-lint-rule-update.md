## TLDR

Update `rule-no-run-zsh` test strings to reference only `bats_run_zsh`.

## What to build

Update `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-run-zsh.bats`:
- The "no violation" test currently uses `bats_run_function` as the clean example. Replace with `bats_run_zsh`.
- The "three occurrences" test uses `bats_run_function fn` as a non-violating line between violations. Replace with `bats_run_zsh fn`.

The rule itself (`rule-no-run-zsh.zsh`) already has the correct error message ("Use bats_run_zsh instead of run zsh") — no code change needed there.

## Behavioral Tests

**no violation when line contains bats_run_zsh**
- Given a bats file line containing `bats_run_zsh`, when the rule runs, then no violation is reported

**violation still detected for run zsh**
- Given a bats file line starting with `run zsh`, when the rule runs, then a `noRunZsh` violation is reported

## Acceptance criteria

- [ ] `rule-no-run-zsh.bats` test strings no longer reference `bats_run_function`
- [ ] `bats rule-no-run-zsh.bats` passes
