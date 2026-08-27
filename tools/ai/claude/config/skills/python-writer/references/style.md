# Python Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolute_path` not `abs_path`)
- Return early to avoid `if/else` nesting

## Return early

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
