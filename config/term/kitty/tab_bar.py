import os
import sys
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

# Add the current directory to Python path so we can import tab_bar_modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tab_bar_modules.projects import initProjectList
from tab_bar_modules.statusbar import initStatusbar
from tab_bar_modules.tabs_first_pass import firstPass
from tab_bar_modules.tabs_second_pass import secondPass

initProjectList()
initStatusbar()


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
    if extra_data.for_layout:
        firstPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )
    else:
        secondPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )

    return screen.cursor.x
