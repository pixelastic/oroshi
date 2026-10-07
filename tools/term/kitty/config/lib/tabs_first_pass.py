from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData

from lib import redraw, reload, tab_switch
from lib.pick_tabs import pick_tabs_to_display
from lib.state import tabState
from lib.tab_data import build_tab_data


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
    # At the start of a new render cycle (first tab), reset the list of tabs
    # and check for reload/redraw
    if index == 1:
        tabState["allTabIds"] = []
        reload.check()
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

    # Track the active tab as we encounter it
    if tabData.get("isActive"):
        tabState["activeTabId"] = id

    # Keep the list of allTabIds up to date. As this method can be called
    # several times on the same tab, we make sure to not duplicate entries
    if id not in tabState["allTabIds"]:
        tabState["allTabIds"].append(id)

    # If this was the last tab, we can now define which tab should be displayed
    if is_last:
        pick_tabs_to_display(screen)
        # Fire any on_tab_switch callback
        tab_switch.check()
        # Cleanup any loose ends, so next redraw starts clean
        redraw.cleanup()
