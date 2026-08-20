# Go Style

- No abbreviated variable names (`absolutePath` not `absPath`)
- Named return values only when they clarify the signature, not for naked returns

## Return early

No avoidable nesting. Guard clauses at the top, happy path at the bottom.

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

Extract when a function does more than one thing. Each function should have a single responsibility.

## Package-level functions

Prefer standalone functions over methods when there is no state to carry. Use methods on structs when multiple operations share state.
