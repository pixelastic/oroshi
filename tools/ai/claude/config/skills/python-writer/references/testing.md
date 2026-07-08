# pytest Testing

## File naming

- Test files: `test_<module>.py` in a `__tests__/` sibling directory
- Run with: `python-test <filepath>`

## Writing a test

```python
def test_<behavior>():
    result = function_under_test(args)
    assert result == expected
```

## conftest.py

Place at the **project root** (same level as `pyproject.toml`), not inside `__tests__/`.

Use it for:
- Shared fixtures available across all tests
- Stubbing unavailable imports via `sys.modules`

## Stubbing unavailable imports

Some modules are not importable outside their runtime. Stub them in `conftest.py`:

```python
import sys
from unittest.mock import MagicMock

sys.modules["some_runtime"] = MagicMock()
sys.modules["some_runtime.submodule"] = MagicMock()
```

Any file that `import`s those modules will receive the mock instead of failing.

## Parametrize

Use `@pytest.mark.parametrize` to test the same behavior with multiple inputs:

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    ("Hello World", "hello-world"),
    ("foo BAR", "foo-bar"),
    ("already-slug", "already-slug"),
])
def test_slugify(input, expected):
    assert slugify(input) == expected
```

## Running tests

```bash
python-test ./path/to/test_file.py       # single file
python-test ./path/to/__tests__/         # whole directory
```
