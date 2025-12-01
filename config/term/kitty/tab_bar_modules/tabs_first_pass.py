from kitty.fast_data_types import Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from tab_bar_modules.projects import getProjectData
from tab_bar_modules.tabs import (
    getTabWidth,
    getActiveTabIndex,
    tabState,
    getTabsKeys,
)
from tab_bar_modules.statusbar import getStatusbarWidth


# First pass:
# We don't draw anything, but we gather all needed information for drawing
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
    tabData = parseRawTabData(tab, draw_data)
    title = tabData["title"]
    icon = tabData["icon"]
    isActive = tabData["isActive"]
    isFullscreen = tabData["isFullscreen"]
    defaultBg = tabData["defaultBg"]
    fg = tabData["fg"]
    bg = tabData["bg"]

    # Build the title with icon, name and potential full-screen icon
    title = f" {icon}{title} "
    if isFullscreen:
        title = f"{title}󰈈 "

    # Save data in the state
    updateDataTab(index, "index", "test")
    updateDataTab(index, "title", title)
    updateDataTab(index, "isActive", isActive)
    updateDataTab(index, "fg", fg)
    updateDataTab(index, "bg", bg)
    updateDataTab(index, "separatorFg", bg)
    updateDataTab(index, "separatorBg", defaultBg)

    # Update the separator bg if we have tab after this one
    nextTab = extra_data.next_tab
    if nextTab:
        nextTabData = parseRawTabData(nextTab, draw_data)
        updateDataTab(index, "separatorBg", nextTabData.get("bg"))

    # Now that we have all the tabs, we need to decide which one we want to
    # actually display in case we don't have enough room
    if is_last:
        pickTabsToDisplay(screen)


# Parses raw data about the tab, as returned by kitty, into a flat object
def parseRawTabData(tab: TabBarData, draw_data: DrawData):
    # Quick fail if no tab
    if not tab:
        return {}

    # Default values
    defaultBg = as_rgb(int(draw_data.default_bg))
    defaultInactiveFg = as_rgb(int(draw_data.inactive_fg))
    defaultInactiveBg = as_rgb(int(draw_data.inactive_bg))
    defaultActiveFg = as_rgb(int(draw_data.active_fg))
    defaultActiveBg = as_rgb(int(draw_data.active_bg))

    # Find info from tab as passed by Kitty
    tabTitle = tab.title
    tabIndex = tab.index
    tabIsFullscreen = tab.layout_name == "stack"
    tabIsActive = tab.is_active

    # Find info from the list of projects if one matches the same name
    projectData = getProjectData(tabTitle)
    tabIcon = projectData.get("icon", "")

    tabData = {
        "title": tabTitle,
        "index": tabIndex,
        "isFullscreen": tabIsFullscreen,
        "icon": tabIcon,
        "isActive": tabIsActive,
        "defaultBg": defaultBg,
    }

    if tabIsActive:
        # Active tab, use project colors if defined
        tabData["fg"] = projectData.get("fg", defaultActiveFg)
        tabData["bg"] = projectData.get("bg", defaultActiveBg)
    else:
        # Inactive tab, use inactive colors
        tabData["bg"] = projectData.get("bgInactive", defaultInactiveBg)
        tabData["fg"] = projectData.get("bg", defaultInactiveFg)

    return tabData


def setDisplayedTabs(tabs):
    tabState["displayedList"] = tabs


# Define the allowlist of tabs we want displayed, based on the available space
def pickTabsToDisplay(screen: Screen):
    # Gathering metrics about the layout
    screenWidth = screen.columns
    statusBarWidth = getStatusbarWidth()
    tabBarMaxWidth = screenWidth - statusBarWidth
    tabsKeys = getTabsKeys()
    tabBarActualWidth = sum(getTabWidth(tab) for tab in tabsKeys)

    # If everything fits, we keep all tabs
    if tabBarActualWidth <= tabBarMaxWidth:
        setDisplayedTabs(tabsKeys)
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
        *(list(range(activeTabIndex + 2, max(tabsKeys)))),
    ]

    # We iterate through the list of indices, adding the tab if we have enough
    # space, and decreasing the available space as we go
    availableSpaceLeft = tabBarMaxWidth
    displayedList = []

    for tabIndex in tabPriorityIndex:
        # Skip if index is out of bounds
        if tabIndex not in tabsKeys:
            continue

        tabWidth = getTabWidth(tabIndex)

        # Stop if we don't have space anymore
        if tabWidth > availableSpaceLeft:
            break

        displayedList.append(tabIndex)
        availableSpaceLeft -= tabWidth

    setDisplayedTabs(displayedList)


# Update the tab state
def updateDataTab(index, key, value):
    if not tabState["data"].get(index):
        tabState["data"][index] = {}

    tabState["data"][index][key] = value
