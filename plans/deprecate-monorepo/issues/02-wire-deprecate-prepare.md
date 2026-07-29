## TLDR

Replace inline npm detection in `deprecate-prepare` with `npm-name` call.

## What to build

In `scripts/bin/ai/deprecate/deprecate-prepare`, replace the 4-line block at lines 54-58:

```zsh
local packageName=""
if [[ "$clonedAt" != "" && -f "$clonedAt/package.json" ]] && ! yarn-package-is-private "$clonedAt"; then
  packageName="$(yarn-package-name "$clonedAt")"
fi
```

With a single `npm-name` call that handles the monorepo fallback internally. Use `|| true` to prevent `set -e` from triggering on empty results.

## Scaffolding Tests

**Wiring check**
- `deprecate-prepare` no longer calls `yarn-package-is-private` or `yarn-package-name` directly — it delegates to `npm-name`

Note: this is a scaffolding test because it verifies the structural change (delegation to `npm-name`), not behavior. The behavioral coverage lives in issue 01's tests.

## Acceptance criteria

- [ ] `deprecate-prepare` calls `npm-name` instead of inline logic
- [ ] Existing `deprecate-prepare.bats` tests still pass
- [ ] `zsh-lint` passes on the modified file
