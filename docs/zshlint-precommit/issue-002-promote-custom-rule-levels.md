## PRD

[zshlint-precommit/PRD.md](./PRD.md)

## What to build

Promote all custom zshlint rules from `warning` or `style` level to `error`. The six rules affected are: `noWhileRead`, `noManualArgParsing`, `noGroupedLocals`, `noExternalBasename`, `singleEqualsInTest` (currently `warning` or `style`). `localOrReturn` is already `error` and needs no change.

After this change, every custom rule violation appears as `error` in zshlint's JSON output. Rules that produce too many false positives can be downgraded back to `warning` on a case-by-case basis.

## Acceptance criteria

- [ ] `noWhileRead` emits `error` level
- [ ] `noManualArgParsing` emits `error` level
- [ ] `noGroupedLocals` emits `error` level
- [ ] `noExternalBasename` emits `error` level
- [ ] `singleEqualsInTest` emits `error` level
- [ ] `localOrReturn` remains `error` level (unchanged)
- [ ] `zshlint` on a file triggering any custom rule shows `"level": "error"` in JSON output

## Blocked by

None — can start immediately.
