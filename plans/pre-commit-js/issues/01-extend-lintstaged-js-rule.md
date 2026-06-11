## TLDR

Widen the lint-staged JS pattern from `scripts/bin/**/*.js` to `**/*.js`.

## What to build

Replace the existing `scripts/bin/**/*.js` lint-staged entry with `**/*.js`.
The new pattern is a strict superset, so the old entry is removed rather than kept alongside (to avoid running lint+test twice on files under `scripts/bin/`).

The two commands attached to the rule stay unchanged:
- `yarn run lint:fix --js` — runs ESLint only (the `--js` flag scopes aberlaas to the JS linter)
- `yarn run test --fail-fast --related` — runs Vitest in related mode; exits 0 silently when no related tests exist

## Behavioral Tests

None — config file is the artifact.

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `lintstaged.config.js` uses `**/*.js` instead of `scripts/bin/**/*.js`
- [ ] The `--js` and `--fail-fast --related` flags are preserved
- [ ] No duplicate JS lint+test entry remains in the config
- [ ] Staging a root config file (e.g. `prettier.config.js`) triggers lint on commit
- [ ] Staging a `tools/` JS file triggers lint on commit
