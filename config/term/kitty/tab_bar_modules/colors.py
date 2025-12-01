from kitty.fast_data_types import get_options
from kitty.utils import color_as_int
from kitty.tab_bar import as_rgb

kittyOptions = get_options()


# Get a cursor color from an int
# Kitty expects screen.cursor.x/y to be in a specific format
# This will convert a color number (0-256, as defined in colors.conf) to the
# expected format
def getCursorColor(colorNumber: int):
    return as_rgb(color_as_int(getattr(kittyOptions, f"color{colorNumber}")))
