from kitty.fast_data_types import get_options
from kitty.utils import color_as_int
from kitty.tab_bar import as_rgb

kittyOptions = get_options()


# Convert an ANSI color index (0-256, as defined in colors.conf) to Kitty's
# internal RGB format (used for cursor, tab, and statusbar colors)
def ansi_to_kitty(colorNumber: int):
    return as_rgb(color_as_int(getattr(kittyOptions, f"color{colorNumber}")))
