# Golgoth

Meta-package of often-used dependencies.

- `_` (lodash) and `pMap` are almost always used
- `pProps`, `dayjs`, `yoctocolors`, `query-string` and `time-span` are used in specific cases
- `got`, `pify` and `pAll` are rarely used
- Usage is `import { _, dayjs, pMap } from 'golgoth'`

## Lodash (`_`)

- Use `_.chain()` whenever you have 2+ operations in sequences
- Use `_.each` and `_.map` instead of `for` loop
