import json
import sys
import os
from pprint import pprint

# Add the current directory to Python path so we can import tab_bar_modules
_current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _current_dir)

from kitty.fast_data_types import (
    Screen,
    add_timer,
    get_options,
)
from kitty.utils import color_as_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
)

from tab_bar_modules.colors import getCursorColor
from tab_bar_modules.projects import initProjectList, getProjectData
from tab_bar_modules.statusbar import (
    initStatusbar,
    checkForForcedRefresh,
    drawStatusbar,
    getStatusbarWidth,
)
from tab_bar_modules.tabs import oroshiDrawTab

KITTY_OPTIONS = get_options()
initStatusbar()
initProjectList()


# Default kitty method called each time the statusbar needs to be displayed.
# Every print statement in this method is swallowed, so we'll call our own
# method instead for easier debugging.
def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    oroshiDrawTab(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )

    return screen.cursor.x
