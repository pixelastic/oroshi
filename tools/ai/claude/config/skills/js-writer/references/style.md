# JavaScript Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolutePath` not `absPath`)
- Return early to avoid `if/else` nesting
- Only `try/catch` when acting on the error before rethrowing

## Return early

**Before:**

```javascript
function process(value) {
  if (value !== null) {
    if (value > 0) {
      return value * 2;
    } else {
      return 0;
    }
  } else {
    return null;
  }
}
```

**After:**

```javascript
function process(value) {
  if (value === null) {
    return null;
  }
  if (value <= 0) {
    return 0;
  }
  return value * 2;
}
```

Also applies inside callbacks:

```javascript
_.each(items, (item) => {
  if (!item.enabled) {
    return;
  }

  if (item.type === 'special') {
    handleSpecial(item);
    return;
  }

  handleDefault(item);
});
```

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
