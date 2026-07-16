from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from lib import redraw
from lib.statusbar import draw_statusbar
from lib.state import tabState


# Second pass:
# This method will be called on each tab in sequence, after first_pass has been
# called on them.
# We will read the metadata gathered in first_pass, and draw the tabs accordingly.
def second_pass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    tab_id = tab.tab_id
    tab_data = tabState["manifest"][tab_id]

    # Track active tab as we encounter it
    if tab_data.get("isActive"):
        tabState["activeTabId"] = tab_id

    # Display only if we have enough room
    if tab_id in tabState["displayedTabIds"]:
        draw_tab_item(tab_data, screen)

    # Once we've drawn the last tab, our job is almost done
    if is_last:
        # Draw the statusbar, we have all the needed info
        draw_statusbar(screen)
        # Cleanup any loose ends, so next redraw starts clean
        redraw.cleanup()
        redraw.schedule_attention_clear()

    return screen.cursor.x


# Draw a tab
def draw_tab_item(tab_data, screen):
    # Draw tab
    screen.cursor.fg = tab_data["fg"]
    screen.cursor.bg = tab_data["bg"]
    screen.draw(tab_data["title"])

    # Draw separator
    screen.cursor.bg = tab_data["separatorBg"]
    screen.cursor.fg = tab_data["separatorFg"]
    screen.draw("")
