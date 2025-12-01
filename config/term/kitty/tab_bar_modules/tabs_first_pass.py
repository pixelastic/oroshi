from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from tab_bar_modules.tabs import (
    getTabData,
    getTabWidth,
    getActiveTabIndex,
    tabState,
    getTabsKeys,
    getTabsValues,
)
from tab_bar_modules.statusbar import getStatusbarWidth


# First pass:
# We don't draw anythong, but we gather all needed information for drawing
# during the second pass
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
    # Get raw data
    tabData = getTabData(tab, draw_data)
    tabTitleName = tabData["title"]
    tabTitleIcon = tabData["icon"]
    tabIsActive = tabData["isActive"]
    tabFg = tabData["fg"]
    tabBg = tabData["bg"]

    # Build the title with icon, name and potential full-screen icon
    tabTitle = f" {tabTitleIcon}{tabTitleName} "
    tabIsFullscreen = tabData["isFullscreen"]
    if tabIsFullscreen:
        tabTitle = f"{tabTitle}󰈈 "

    # Also keep info about the next tab, for smoother separator transitions
    defaultBg = as_rgb(int(draw_data.default_bg))
    nextTabData = getTabData(extra_data.next_tab, draw_data)
    nextTabBg = nextTabData.get("bg", defaultBg)
    nextTabFg = tabBg

    # Save data in the state
    tabState["data"][index] = {
        "index": index,
        "title": tabTitle,
        "isActive": tabIsActive,
        "fg": tabFg,
        "bg": tabBg,
        "nextFg": nextTabFg,
        "nextBg": nextTabBg,
    }

    # Now that we have all the tabs, we need to decide which one we want to
    # actually display in case we don't have enough room
    if is_last:
        pickTabToDisplay(screen)


# Define the allowlist of tabs we want displayed, based on the available space
def pickTabToDisplay(screen: Screen):
    # Gathering metrics about the layout
    screenWidth = screen.columns
    statusBarWidth = getStatusbarWidth()
    tabBarMaxWidth = screenWidth - statusBarWidth
    tabBarActualWidth = sum(getTabWidth(tab) for tab in getTabsValues())

    # If everything fits, we keep all tabs
    if tabBarActualWidth <= tabBarMaxWidth:
        tabState["displayedList"] = list(getTabsKeys())
        return

    # If not everything fits, we keep the following tabs until we run out of
    # space:
    # - The active tab
    # - The tab on its right, and the tab on its left
    # - Any tab on its left
    # - Any tab on its right
    activeTabIndex = getActiveTabIndex()
    tabPriorityIndex = [
        activeTabIndex,
        activeTabIndex + 1,
        activeTabIndex - 1,
        *(list(range(activeTabIndex - 2, 0, -1))),
        *(list(range(activeTabIndex + 2, max(getTabsKeys())))),
    ]

    # We iterate through the list of indices, adding the tab if we have enough
    # space, and decreasing the available space as we go
    availableSpaceLeft = tabBarMaxWidth
    tabState["displayedList"] = []

    for tabIndex in tabPriorityIndex:
        # Skip if index is out of bounds
        if tabIndex not in getTabsKeys():
            continue

        tab = tabState["data"][tabIndex]
        tabWidth = getTabWidth(tab)

        # Stop if we don't have space anymore
        if tabWidth > availableSpaceLeft:
            break

        tabState["displayedList"].append(tabIndex)
        availableSpaceLeft -= tabWidth
