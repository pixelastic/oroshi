# Global state for tabs
tabState = {"data": {}, "displayedList": []}


# Return a list of all tab keys
def getTabsKeys():
    return tabState["data"].keys()


# Return the display width of a given tab, including space for the separator
def getTabWidth(tabIndex):
    separatorLength = 1

    tab = tabState["data"][tabIndex]
    return len(tab["title"]) + separatorLength


# Return the currently active tab index
def getActiveTabIndex():
    for tab in tabState["data"].values():
        if tab["isActive"]:
            return tab["index"]
