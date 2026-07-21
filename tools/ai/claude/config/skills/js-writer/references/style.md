# Style

- camelCase for everything
- No abbreviated variable names (`absolutePath` not `absPath`)
- Return early — guard clauses at the top, happy path at the bottom.
- DO NOT use `.then()`, always `async/await`
- JSDoc required on all functions

## Error Handling

- Only `try/catch` when acting on the error before rethrowing

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
