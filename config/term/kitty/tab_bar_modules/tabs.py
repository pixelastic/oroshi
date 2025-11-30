from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
)

from tab_bar_modules.projects import getProjectData
from tab_bar_modules.statusbar import (
    drawStatusbar,
    getStatusbarWidth,
)

# Global state for tabs
ALL_TABS = {}
TAB_ALLOWED_LIST = []


# TABS


# On the first pass, we don't draw anything but gather all layout information
# about the tabs we'll draw in the second pass
def oroshiTabFirstPass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global ALL_TABS

    # Get raw data
    tabData = oroshiTabData(tab, draw_data)
    tabTitleName = tabData["title"]
    tabTitleIcon = tabData["icon"]
    tabIsActive = tabData["isActive"]
    tabFg = tabData["fg"]
    tabBg = tabData["bg"]

    # Build the title with icon, name and potential full-screen icon
    tabTitle = f" {tabTitleIcon}{tabTitleName} "
    tabIsFullscreen = tabData["isFullscreen"]
    if tabIsFullscreen:
        tabTitle = f"{tabTitle} "

    # Also keep info about the next tab, for smoother separator transitions
    defaultBg = as_rgb(int(draw_data.default_bg))
    nextTabData = oroshiTabData(extra_data.next_tab, draw_data)
    nextTabBg = nextTabData.get("bg", defaultBg)
    nextTabFg = tabBg

    # Save data in a shared list
    ALL_TABS[index] = {}
    ALL_TABS[index]["index"] = index
    ALL_TABS[index]["title"] = tabTitle
    ALL_TABS[index]["isActive"] = tabIsActive
    ALL_TABS[index]["fg"] = tabFg
    ALL_TABS[index]["bg"] = tabBg
    ALL_TABS[index]["nextFg"] = nextTabFg
    ALL_TABS[index]["nextBg"] = nextTabBg

    # Now that we have all the tabs, we need to decide which one we want to
    # actually display in case we don't have enough room
    if is_last:
        oroshiDefineTabsToDisplay(screen)


# Define the allowlist of tabs we want displayed, based on the available space
def oroshiDefineTabsToDisplay(screen: Screen):
    global ALL_TABS
    global TAB_ALLOWED_LIST

    # Gathering metrics about the layout
    screenWidth = screen.columns
    statusBarWidth = getStatusbarWidth()
    tabBarMaxWidth = screenWidth - statusBarWidth
    tabBarActualWidth = sum(oroshiTabWidth(tab) for tab in ALL_TABS.values())

    # If everything fits, we keep all tabs
    if tabBarActualWidth <= tabBarMaxWidth:
        TAB_ALLOWED_LIST = list(ALL_TABS.keys())
        return

    # If not everything fits, we keep the following tabs until we run out of
    # space:
    # - The active tab
    # - The tab on its right, and the tab on its left
    # - Any tab on its left
    # - Any tab on its right
    activeTabIndex = oroshiGetActiveTabIndex()
    tabPriorityIndex = [
        activeTabIndex,
        activeTabIndex + 1,
        activeTabIndex - 1,
        *(list(range(activeTabIndex - 2, 0, -1))),
        *(list(range(activeTabIndex + 2, max(ALL_TABS.keys())))),
    ]

    # We iterate through the list of indices, adding the tab if we have enough
    # space, and decreasing the available space as we go
    availableSpaceLeft = tabBarMaxWidth
    TAB_ALLOWED_LIST = []

    for tabIndex in tabPriorityIndex:
        # Skip if index is out of bounds
        if tabIndex not in ALL_TABS:
            continue

        tab = ALL_TABS[tabIndex]
        tabWidth = oroshiTabWidth(tab)

        # Stop if we don't have space anymore
        if tabWidth > availableSpaceLeft:
            break

        TAB_ALLOWED_LIST.append(tabIndex)
        availableSpaceLeft -= tabWidth


# On the second pass, we have all the layout information, this is when we
# actually draw the tabs
def oroshiTabSecondPass(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    global ALL_TABS
    global TAB_ALLOWED_LIST

    # Only draw it if we have enough space
    if index in TAB_ALLOWED_LIST:
        # Read data from ALL_TABS
        tabData = ALL_TABS[index]
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
        screen.draw("")

    # If last tab, also draw the status bar
    if is_last:
        drawStatusbar(screen)

    return screen.cursor.x


# Returns a hash of useful data for a given tab
def oroshiTabData(tab: TabBarData, draw_data: DrawData):
    # Quick fail if no tab
    if not tab:
        return {}

    # Default values
    defaultInactiveFg = as_rgb(int(draw_data.inactive_fg))
    defaultInactiveBg = as_rgb(int(draw_data.inactive_bg))
    defaultActiveFg = as_rgb(int(draw_data.active_fg))
    defaultActiveBg = as_rgb(int(draw_data.active_bg))

    # Find info from tab as passed by Kitty
    tabTitle = tab.title
    tabIsFullscreen = tab.layout_name == "stack"
    tabIsActive = tab.is_active

    # Find info from the list of projects if one matches the same name
    projectData = getProjectData(tabTitle)
    tabIcon = projectData.get("icon", "")

    tabData = {
        "title": tabTitle,
        "isFullscreen": tabIsFullscreen,
        "icon": tabIcon,
        "isActive": tabIsActive,
    }

    # Active tab, use project colors if defined
    if tabIsActive:
        tabData["fg"] = projectData.get("fg", defaultActiveFg)
        tabData["bg"] = projectData.get("bg", defaultActiveBg)
    else:
        # Inactive tab are also colored, but with dimmer versions of the active tabs
        tabData["bg"] = projectData.get("bgInactive", defaultInactiveBg)

        # Foreground is the active background, or default if not defined
        if "bg" in projectData:
            tabData["fg"] = projectData["bg"]
        else:
            tabData["fg"] = defaultInactiveFg

    return tabData


# Return the display width of a given tab, including space for the separator
def oroshiTabWidth(tab):
    separatorLength = 1
    return len(tab["title"]) + separatorLength


# Return the currently active tab index
def oroshiGetActiveTabIndex():
    global ALL_TABS
    for tab in ALL_TABS.values():
        if tab["isActive"]:
            return tab["index"]


# Main drawing function that delegates to first or second pass
def oroshiDrawTab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if extra_data.for_layout:
        oroshiTabFirstPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )
    else:
        oroshiTabSecondPass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )

    return screen.cursor.x
