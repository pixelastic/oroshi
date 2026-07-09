import os
import sys
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

# Add the current directory to Python path so we can import lib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lib.projects as projects
import lib.statusbar as statusbar
import lib.tabs_first_pass as tabs_first_pass
import lib.tabs_second_pass as tabs_second_pass

_initialized = False


# Default kitty method called each time the statusbar needs to be displayed.
# It is always called twice, once to gather layout information, and once to actually
# draw the tabs.
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
    # Init all the data only once
    global _initialized
    if not _initialized:
        projects.init()
        statusbar.init()
        _initialized = True

    args = (
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    if extra_data.for_layout:
        tabs_first_pass.first_pass(*args)
    else:
        tabs_second_pass.second_pass(*args)

    return screen.cursor.x
