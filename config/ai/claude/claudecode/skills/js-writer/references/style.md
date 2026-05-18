# Style

- camelCase for everything
- `_.chain()` for 2+ lodash ops; direct method for one op
- DO NOT use `.then()`, always `async/await`
- Only `try/catch` when acting on the error before rethrowing
- JSDoc required on all functions (exported and `__` private)

## Loops

- DO NOT use `for` loops, prefer `_.each`, `_.map` or `pMap`

## Error Handling

```javascript
import { firostError } from 'firost';
export async function processWithCleanup(path) {
  const tmp = await createTemp();
  try {
    return await process(tmp);
  } catch (error) {
    await remove(tmp);
    throw firostError('MY_MODULE_PROCESS_ERROR', 'An error occured during process');
  }
}
```
