# Modules

- DO NOT use `require`/`module.exports`, always use ES6 `import`/`export`
- DO NOT use `export default`, always named exports
- Include `.js` extension on local imports

## Private Methods (`__`)

The exported function is the only top-level function in a module.

- Local helpers always go in `__`, mocked or not.
- Imports go in `__` only when a test mocks them to block a side effect (for example `run`, `exit`).
- If nothing mocks an import, import and call it directly.

```javascript
import { run } from 'firost';
import { formatEntry } from './formatEntry.js';

export let __;

/**
 * Run the command for an entry
 * @param {string} name - Entry name
 * @returns {object} Command result
 */
export async function publicFn(name) {
  const command = __.buildCommand(name);
  return await __.run(command);
}

__ = {
  // Local helper: always in `__`
  /**
   * @param {string} name - Entry name
   * @returns {string} Shell command
   */
  buildCommand(name) { /* ... */ },
  // Mocked import: blocks the side effect in tests
  run,
};
```

`formatEntry` stays a direct import: no test mocks it.
