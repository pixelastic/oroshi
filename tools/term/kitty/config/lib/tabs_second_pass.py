from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from lib import redraw, tab_data, tab_switch
from lib.helper import ansi_to_kitty
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
    tab_item = tabState["manifest"][tab_id]

    # Track active tab as we encounter it
    if tab_item.get("isActive"):
        tabState["activeTabId"] = tab_id

    # Display only if we have enough room
    if tab_id in tabState["displayedTabIds"]:
        draw_tab_item(tab_item, screen)

    # Once we've drawn the last tab, our job is almost done
    if is_last:
        # Draw the statusbar, we have all the needed info
        draw_statusbar(screen)
        # Fire any on_tab_switch callback
        tab_switch.check()
        # Cleanup any loose ends, so next redraw starts clean
        redraw.cleanup()

    return screen.cursor.x


# Draw a tab
def draw_tab_item(tab_item, screen):
    # Draw tab
    screen.cursor.fg = tab_item["fg"]
    screen.cursor.bg = tab_item["bg"]
    screen.draw(tab_item["title"])

    # Draw attention icon in ai color
    if tab_item["attentionIcon"]:
        screen.cursor.fg = ansi_to_kitty(tab_data._colors["ai"]["ansi"])
        screen.draw(tab_item["attentionIcon"])

    # Draw separator
    screen.cursor.bg = tab_item["separatorBg"]
    screen.cursor.fg = tab_item["separatorFg"]
    screen.draw("")
