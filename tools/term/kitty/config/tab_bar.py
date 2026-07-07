import os
import sys
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

# Add the current directory to Python path so we can import tab_bar_modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tab_bar_modules.projects as projects_module
import tab_bar_modules.statusbar as statusbar_module
import tab_bar_modules.tabs_first_pass as tabs_first_pass_module
import tab_bar_modules.tabs_second_pass as tabs_second_pass_module

projects_module.init_project_list()
statusbar_module.init_statusbar()


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
        tabs_first_pass_module.firstPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )
    else:
        tabs_second_pass_module.secondPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )

    return screen.cursor.x
