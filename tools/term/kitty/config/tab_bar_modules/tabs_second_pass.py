from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from tab_bar_modules.statusbar import drawStatusbar
from tab_bar_modules.tabs import tabState


# Second pass:
# This method will be called on each tab in sequence, after firstPass has been
# called on them.
# We will read the metadata gathered in firstPass, and draw the tabs accordingly.
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
    tabId = tab.tab_id
    tabData = tabState["manifest"][tabId]

    # Display only if we have enough room
    if tabId in tabState["displayedTabIds"]:
        drawTab(tabData, screen)

    # Once we've drawn the last tab, our job is almost done
    if is_last:
        # We reset allTabIds, so firstPass can rebuild it next time
        tabState["allTabIds"] = []
        # We draw the status bar
        drawStatusbar(screen)

    return screen.cursor.x


# Draw a tab
def drawTab(tabData, screen):
    # Draw tab
    screen.cursor.fg = tabData["fg"]
    screen.cursor.bg = tabData["bg"]
    screen.draw(tabData["title"])

    # Draw separator
    screen.cursor.bg = tabData["separatorBg"]
    screen.cursor.fg = tabData["separatorFg"]
    screen.draw("")
