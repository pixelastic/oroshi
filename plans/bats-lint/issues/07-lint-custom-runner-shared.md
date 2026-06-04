## TLDR

Extract the shared runner logic from `bats-lint-custom` and `zshlint-custom` into a reusable helper, eliminating the near-total duplication between the two scripts.

## Problem

`bats-lint-custom` and `zshlint-custom` are ~95% identical. The only differences are:
- Which rule files are sourced and which rule functions are listed
- The disable comment prefix (`bats-lint-disable` vs `zshlint-disable`)

Everything else — input filtering, rule execution loop, prev-line disable suppression, `▮`-to-JSON conversion, exit code — is a verbatim copy. Any bug fix or improvement must be applied twice.

## What to build

A shared autoloaded ZSH function `lint-custom-run` (or similar) that encapsulates the runner logic:

```zsh
# lint-custom-run --disable-prefix <prefix> --rules <fn1> [fn2 ...] -- <files...>
```

The caller (`bats-lint-custom`, `zshlint-custom`) only needs to:
1. Source its rule files
2. Call `lint-custom-run` with the right prefix and rule list

### Suggested location

`tools/term/zsh/config/functions/autoload/lint/lint-custom-run`

(mirrors the `rules-helper` pattern: shared tooling in `tools/`, consumed by scripts in `scripts/`)

## Behavioral Tests

**Delegation works — bats-lint-custom still passes all its tests:**
- All existing `__tests__/bats-lint-custom.bats` tests pass unchanged after the refactor

**Delegation works — zshlint-custom still passes all its tests:**
- All existing `__tests__/zshlint-custom.bats` tests pass unchanged after the refactor

**The shared function is not tested directly** — its contract is fully covered by the two consumer test suites.

## Acceptance criteria

- [ ] A shared helper contains the input-filtering, rule-execution, disable-suppression, and JSON-conversion logic
- [ ] `bats-lint-custom` is reduced to: source rules + call the helper
- [ ] `zshlint-custom` is reduced to: source rules + call the helper
- [ ] All existing `bats-lint-custom` and `zshlint-custom` tests pass unchanged
- [ ] `zshlint` passes on all new/modified ZSH files
