# Go Testing

## File naming

- Test files: `<module>_test.go` in the same package
- Run with: `go-test <filepath>`

## Assertions with testify

Use `assert` for independent checks (test continues on failure) and `require` for guards (test stops on failure).

```go
import (
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestReturnsTrueForValidInput(t *testing.T) {
    result := Validate("good")
    assert.True(t, result)
}

func TestReadsConfig(t *testing.T) {
    config, err := ReadConfig("path")
    require.NoError(t, err)        // stop here if error — no point continuing
    assert.Equal(t, "value", config.Key)
}
```

**Rule of thumb:** `require` when a failure makes the rest of the test meaningless (nil checks, error checks), `assert` for everything else.

## Table-driven tests

Preferred pattern when testing the same function with multiple inputs:

```go
func TestSlugify(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"simple words", "Hello World", "hello-world"},
        {"mixed case", "foo BAR", "foo-bar"},
        {"already slug", "already-slug", "already-slug"},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Slugify(tt.input)
            assert.Equal(t, tt.expected, got)
        })
    }
}
```

## Subtests with t.Run

Use `t.Run` to group related assertions under a single test function:

```go
func TestParser(t *testing.T) {
    t.Run("parses progress lines", func(t *testing.T) {
        e := ParseLine("Counting objects: 100% (5/5), done.")
        assert.Equal(t, Progress, e.Type)
    })
    t.Run("parses error lines", func(t *testing.T) {
        e := ParseLine("fatal: not found")
        assert.Equal(t, Error, e.Type)
    })
}
```

## Section headers

Group related tests with comment headers:

```go
// --- Parsing ---

func TestParsesSimpleInput(t *testing.T) { ... }
func TestParsesComplexInput(t *testing.T) { ... }

// --- Error cases ---

func TestReturnsErrorForEmptyInput(t *testing.T) { ... }
```

## Temporary directories

Use `t.TempDir()` for tests that need filesystem access — automatically cleaned up.

```go
func TestReadsConfig(t *testing.T) {
    root := t.TempDir()
    os.WriteFile(filepath.Join(root, "config.json"), []byte(`{}`), 0o644)
    result, err := ReadConfig(root)
    require.NoError(t, err)
    assert.Equal(t, "default", result.Name)
}
```

## Dependency injection

Pass dependencies as function arguments or struct fields, not globals. Use function types for external commands:

```go
type CommandRunner func(name string, args ...string) (string, error)

func TestCallsExternalCommand(t *testing.T) {
    runner := func(name string, args ...string) (string, error) {
        return "mocked output\n", nil
    }
    result := DoWork(runner)
    assert.Equal(t, "expected", result)
}
```

## Running tests

```bash
go-test ./path/to/file.go          # single package
go-test ./path/to/file_test.go     # test file
```
