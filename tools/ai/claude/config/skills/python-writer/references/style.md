# Python Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolute_path` not `abs_path`)
- Return early to avoid `if/else` nesting
- Write comments that say only what the code shows, and link facts with because, so, but

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

## Comments

Follow [Comments](./comments.md). Write comments with `#`.

Write function docs as `#` comments above the function. Do not write them as a docstring inside the function.

```python
# Convert an ANSI color index (0-256, as defined in colors.conf) to Kitty's
# internal RGB format (used for cursor, tab, and statusbar colors)
def ansi_to_kitty(colorNumber: int):
    return as_rgb(color_as_int(getattr(kittyOptions, f"color{colorNumber}")))
```
