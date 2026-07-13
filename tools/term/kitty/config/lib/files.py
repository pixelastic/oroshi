# Porcelain file I/O helpers.
# Wraps Python's os/open boilerplate into single-call functions, similar to
# firost (JS) and F.* helpers (Lua).
import json
import os


def exists(path):
    """Check if a file or directory exists."""
    return os.path.exists(path)


def read(path):
    """Return the full content of a file as a string."""
    with open(path) as f:
        return f.read()


def read_json(path):
    """Parse a JSON file and return the result."""
    with open(path) as f:
        return json.load(f)


def write(path, content):
    """Overwrite a file with the given content."""
    with open(path, "w") as f:
        f.write(content)


def touch(path):
    """Create an empty file (or truncate an existing one)."""
    with open(path, "w"):
        pass


def remove(path):
    """Delete a file."""
    os.remove(path)
