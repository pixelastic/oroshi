# Python Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolute_path` not `abs_path`)
- Return early to avoid `if/else` nesting
- Write comments in short, simple sentences

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

- Write simple sentences with a verb. Write one idea per sentence.
- Do not chain ideas with commas or "so". Give each idea its own sentence.
- Call each thing by its name, not by a vague reference.
- Describe the steps in the order the code runs them.
