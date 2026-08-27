# Go Style

## Essentials

- Remove duplication by extracting helpers
- Improve readability with clear names. Avoid abbreviations (`absolutePath` not `absPath`)
- Return early to avoid `if/else` nesting
- Named return values only when they clarify the signature, not for naked returns
- Return errors early, wrap with `%w` for context, no bare `panic`
- Extract short functions — one responsibility each
- Prefer standalone functions over methods when there is no state to carry

## Return early

**Before:**

```go
func process(value *int) (int, error) {
    if value != nil {
        if *value > 0 {
            return *value * 2, nil
        } else {
            return 0, nil
        }
    } else {
        return 0, fmt.Errorf("nil value")
    }
}
```

**After:**

```go
func process(value *int) (int, error) {
    if value == nil {
        return 0, fmt.Errorf("nil value")
    }
    if *value <= 0 {
        return 0, nil
    }
    return *value * 2, nil
}
```

## Error handling

Return errors early. Wrap with `%w` for context.

```go
data, err := os.ReadFile(path)
if err != nil {
    return nil, fmt.Errorf("reading %s: %w", path, err)
}
```

No bare `panic`. Return errors to callers.

## Short functions

Extract when a function does more than one thing. Each function should have a
single responsibility.

## Package-level functions

Prefer standalone functions over methods when there is no state to carry. Use
methods on structs when multiple operations share state.
