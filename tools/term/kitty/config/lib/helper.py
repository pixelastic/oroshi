from pprint import pformat
from lib import files
from kitty.fast_data_types import get_options
from kitty.utils import color_as_int
from kitty.tab_bar import as_rgb

# Track if this is the first call to debug
debugState = {"initialized": False}
_debug_file_path = "/home/tim/local/tmp/kittydebug.log"


kittyOptions = get_options()


# Convert an ANSI color index (0-256, as defined in colors.conf) to Kitty's
# internal RGB format (used for cursor, tab, and statusbar colors)
def ansi_to_kitty(colorNumber: int):
    return as_rgb(color_as_int(getattr(kittyOptions, f"color{colorNumber}")))


def debug(variable):
    """
    Pretty print a variable to a debug log file.
    First call clears the file, subsequent calls append.
    """

    # On first call, remove the file if it exists
    if not debugState["initialized"]:
        if files.exists(_debug_file_path):
            files.remove(_debug_file_path)
        debugState["initialized"] = True

    # Pretty print the variable and append to file
    with open(_debug_file_path, "a") as f:
        f.write(pformat(variable))
        f.write("\n")
