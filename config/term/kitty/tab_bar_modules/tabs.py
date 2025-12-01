from kitty.tab_bar import (
    DrawData,
    TabBarData,
    as_rgb,
)

from tab_bar_modules.projects import getProjectData

# Global state for tabs
tabState = {"data": {}, "displayedList": []}


# TABS
# Returns a hash of useful data for a given tab
def getTabData(tab: TabBarData, draw_data: DrawData):
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
def getTabWidth(tab):
    separatorLength = 1
    return len(tab["title"]) + separatorLength


# Return a list of all tab keys
def getTabsKeys():
    return tabState["data"].keys()


# Return a list of all tab values
def getTabsValues():
    return tabState["data"].values()


# Return the currently active tab index
def getActiveTabIndex():
    for tab in getTabsValues():
        if tab["isActive"]:
            return tab["index"]
