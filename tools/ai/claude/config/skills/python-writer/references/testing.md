# pytest Testing

## File naming

- Test files: `test_<module>.py` in a `__tests__/` sibling directory
- Test functions: `test_<behavior>`
- Run with: `python-test <filepath>`. The path can be a test file, a source file with a matching test, or a directory

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


@pytest.mark.parametrize(
    "text,expected",
    [
        ("Hello World", "hello-world"),
        ("foo BAR", "foo-bar"),
        ("already-slug", "already-slug"),
    ],
)
def test_slugify(text, expected):
    assert slugify(text) == expected
```

## Mocking

Use the `mocker` fixture (pytest-mock). It undoes every patch when the test ends.

```python
import lib.helper as helper


def test_ansi_to_kitty_returns_as_rgb_result(mocker):
    mocker.patch("lib.helper.color_as_int", return_value=999)
    mocker.patch("lib.helper.as_rgb", return_value=0xABCDEF)
    assert helper.ansi_to_kitty(42) == 0xABCDEF
```

## Temporary directories

Use the `tmp_path` fixture for tests that need the filesystem. pytest cleans it up.

```python
def test_reads_config(tmp_path):
    (tmp_path / "config.json").write_text("{}")
    assert read_config(tmp_path).name == "default"
```

## Running tests

```bash
python-test ./path/to/test_file.py       # single test file
python-test ./path/to/module.py          # source file, runs its matching test
python-test ./path/to/__tests__/         # whole directory
```
