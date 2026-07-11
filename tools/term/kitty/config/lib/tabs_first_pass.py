from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from lib.tab_data import build_tab_data

from lib import redraw
from lib.pick_tabs import pick_tabs_to_display
from lib.tabs import tabState


# First pass:
# This method will be called on each tab in sequence. It will grab all metadata
# about the tabs, but won't draw anything yet (this is what second_pass is for)
def first_pass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # At the start of a new render cycle (allTabIds is empty), load attention state
    if not tabState["allTabIds"]:
        redraw.check()

    # Format tab data from raw data passed by Kitty
    tabData = build_tab_data(tab, draw_data)
    id = tabData["id"]
    tabData["index"] = index  # We store the index

    # Update the separator bg if we have a tab after this one
    nextTab = extra_data.next_tab
    if nextTab:
        nextTabRaw = build_tab_data(nextTab, draw_data)
        tabData["separatorBg"] = nextTabRaw.get("bg")

    # Save metadata in the manifest
    tabState["manifest"][id] = tabData

    # Keep the list of allTabIds up to date. As this method can be called
    # several times on the same tab, we make sure to not duplicate entries
    if id not in tabState["allTabIds"]:
        tabState["allTabIds"].append(id)

    # If this was the last tab, we can now define which tab should be displayed
    if is_last:
        pick_tabs_to_display(screen)
