from pprint import pformat
import os

# Track if this is the first call to debug
_debug_initialized = False
_debug_file_path = "/home/tim/local/tmp/kittydebug.log"


def debug(variable):
    """
    Pretty print a variable to a debug log file.
    First call clears the file, subsequent calls append.
    """
    global _debug_initialized

    # On first call, remove the file if it exists
    if not _debug_initialized:
        if os.path.exists(_debug_file_path):
            os.remove(_debug_file_path)
        _debug_initialized = True

    # Pretty print the variable and append to file
    with open(_debug_file_path, "a") as f:
        f.write(pformat(variable))
        f.write("\n")
