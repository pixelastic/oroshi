# Python Style

- No abbreviated variable names (`absolutePath` not `absPath`)

## Return early

No avoidable nesting. Guard clauses at the top, happy path at the bottom.

**Before:**

```python
def process(value):
    if value is not None:
        if value > 0:
            result = value * 2
            return result
        else:
            return 0
    else:
        return None
```

**After:**

```python
def process(value):
    if value is None:
        return None
    if value <= 0:
        return 0
    return value * 2
```
