from kitty.fast_data_types import Screen
from tab_bar_modules.tabs import tabState
from tab_bar_modules.statusbar import getStatusbarWidth

# This is based on the length of the  character used as a separator
SEPARATOR_LENGTH = 1


# Define the allowlist of tabs we want displayed, based on the available space
def pickTabsToDisplay(screen: Screen):
    # Gathering metrics about the layout
    screenWidth = screen.columns
    statusBarWidth = getStatusbarWidth()
    # Even with a large statusbar, we still want at least 50 chars for the tabs
    tabBarMaxWidth = max(screenWidth - statusBarWidth, 50)
    tabBarActualWidth = getFullTabBarWidth()

    # If everything fits, we keep all tabs
    if tabBarActualWidth <= tabBarMaxWidth:
        tabState["displayedTabIds"] = tabState["allTabIds"]
        return

    # We define which tabs we want to keep, by order of priority
    activeTabIndex = getActiveTabIndex()
    tabCount = len(tabState["allTabIds"])
    allTabsBefore = list(range(activeTabIndex - 2, 0, -1))
    allTabsAfter = list(range(activeTabIndex + 2, tabCount + 1))
    positionsOfTabsToKeep = [
        activeTabIndex,  # The active tab
        activeTabIndex + 1,  # The tab after the active one
        activeTabIndex - 1,  # The tab before the active one
        *(allTabsBefore),  # All tabs before, from closest to furthest
        *(allTabsAfter),  # All tabs after, from closest to furthest
    ]

    # We will iterate through our list of tabs to keep,
    # until we run out of space
    availableSpaceLeft = tabBarMaxWidth
    displayedTabIds = []
    for tabPosition in positionsOfTabsToKeep:
        # Note: tabPosition is a kitty-index (1-based),
        # while allTabIds is a python array (0-based).

        # Exclude positions out of bounds
        if tabPosition <= 0 or tabPosition > tabCount:
            continue

        # Find the tab width
        # Note: We convert kitty position to python index to metadata
        tabId = tabState["allTabIds"][tabPosition - 1]
        tabWidth = getTabWidth(tabId)

        # Stop if we don't have space anymore
        if tabWidth > availableSpaceLeft:
            break

        displayedTabIds.append(tabId)
        availableSpaceLeft -= tabWidth

    tabState["displayedTabIds"] = displayedTabIds


# Returns the width of a given tab
def getTabWidth(tabId):
    return len(tabState["manifest"][tabId]["title"]) + SEPARATOR_LENGTH


# Returns the full tabBar width if we display all tabs
def getFullTabBarWidth():
    totalWidth = 0
    for tabId in tabState["allTabIds"]:
        totalWidth += getTabWidth(tabId)
    return totalWidth


# Return the currently active tab index
def getActiveTabIndex():
    for tabId in tabState["allTabIds"]:
        tabData = tabState["manifest"][tabId]
        if tabData["isActive"]:
            return tabData["index"]
