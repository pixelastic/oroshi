from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from tab_bar_modules.parseRawTabData import parseRawTabData

from tab_bar_modules.pickTabsToDisplay import pickTabsToDisplay
from tab_bar_modules.tabs import tabState


# First pass:
# This method will be called on each tab in sequence. It will grab all metadata
# about the tabs, but won't draw anything yet (this is what secondPass is for)
def firstPass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Format tab data from raw data passed by Kitty
    tabData = parseRawTabData(tab, draw_data)
    id = tabData["id"]
    tabData["index"] = index  # We store the index

    # Update the separator bg if we have a tab after this one
    nextTab = extra_data.next_tab
    if nextTab:
        nextTabRaw = parseRawTabData(nextTab, draw_data)
        tabData["separatorBg"] = nextTabRaw.get("bg")

    # Save metadata in the manifest
    tabState["manifest"][id] = tabData

    # Keep the list of allTabIds up to date. As this method can be called
    # several times on the same tab, we make sure to not duplicate entries
    if id not in tabState["allTabIds"]:
        tabState["allTabIds"].append(id)

    # If this was the last tab, we can now define which tab should be displayed
    if is_last:
        pickTabsToDisplay(screen)
