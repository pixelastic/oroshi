# Aberlaas

Testing, linting, formatting, releasing, etc.

## Test
- `yarn run test <filepath>`
- `yarn run test --fail-fast <filepath>` to stop on first failure
- `vite.config.js` for config

## Lint
- `yarn run lint:fix` to fix most lint issues and display the others
- `eslint.config.js`, `prettier.config.js`, `stylelint.config.js` for config

## Precommit
- Test and lint ran on each commit
- `lintstaged.config.js` for config
