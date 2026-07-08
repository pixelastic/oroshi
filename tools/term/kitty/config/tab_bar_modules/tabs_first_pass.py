import os
from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData
from tab_bar_modules.tab_data import build_tab_data

from tab_bar_modules.pick_tabs import pick_tabs_to_display
from tab_bar_modules.tabs import tabState

# Attention file — list of tab IDs that need user attention
_ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


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
        if os.path.exists(_ATTENTION_FILE):
            with open(_ATTENTION_FILE) as f:
                tabState["attentionIds"] = {line.strip() for line in f if line.strip()}
        else:
            tabState["attentionIds"] = set()

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
