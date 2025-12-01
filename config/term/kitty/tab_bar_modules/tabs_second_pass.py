from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from tab_bar_modules.statusbar import drawStatusbar
from tab_bar_modules.tabs import tabState


# On the second pass, we have all the layout information, this is when we
# actually draw the tabs
def secondPass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Only draw it if we have enough space
    if index in tabState["displayedList"]:
        # Read data from ALL_TABS
        tabData = tabState["data"][index]
        tabTitle = tabData["title"]
        tabFg = tabData["fg"]
        tabBg = tabData["bg"]
        nextBg = tabData["nextBg"]
        nextFg = tabData["nextFg"]

        # Draw tab
        screen.cursor.fg = tabFg
        screen.cursor.bg = tabBg
        screen.draw(tabTitle)

        # Draw separator
        screen.cursor.bg = nextBg
        screen.cursor.fg = nextFg
        screen.draw("")

    # If last tab, also draw the status bar
    if is_last:
        drawStatusbar(screen)

    return screen.cursor.x
