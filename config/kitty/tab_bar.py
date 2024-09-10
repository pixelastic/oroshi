import os
import json
import subprocess
from pprint import pprint
from kitty.boss import get_boss
from kitty.fast_data_types import (
    Screen,
    add_timer,
    get_options,
)
from kitty.utils import color_as_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    Formatter,
    TabBarData,
    as_rgb,
    draw_attributed_string,
)

KITTY_OPTIONS = get_options()

# List of items to display in the status bar.
# Order is important, and number is the refresh delay (in seconds)
STATUSBAR_DEFINITION = [
    "spotify:5",
    "battery:60",
    "cpu:30",
    "ram:30",
    # "ping:30",
    "clock:60",
    "dropbox:300",
]


# HELPERS {{{
# Get a cursor color from an int
# Kitty expects screen.cursor.x/y to be in a specific format
# This will convert a color number (0-256, as defined in colors.conf) to the
# expected format
def _oroshi_get_cursor_color(colorNumber: int):  # {{{
    global KITTY_OPTIONS
    return as_rgb(color_as_int(getattr(KITTY_OPTIONS, f"color{colorNumber}")))


# }}}


# Mark the tab manager as dirty so Kitty will redraw it whenever it can
def _oroshi_refresh_statusbar():  # {{{
    kittyTabManager = get_boss().active_tab_manager
    if kittyTabManager is not None:
        kittyTabManager.mark_tab_bar_dirty()


# }}}


# }}}


# TABS {{{
# ALL_PROJECTS {{{
# Set the ALL_PROJECTS object, that contains name, icons and colors of all
# projects
def _oroshi_init_project_list():
    global ALL_PROJECTS
    ALL_PROJECTS = {}

    # This file is automatically generated from its sister projects.zsh in the
    # same folder
    jsonPath = "/home/tim/.oroshi/config/zsh/theming/env/projects.json"
    rawProjectData = json.load(open(jsonPath, "r"))

    # First, build an object with one key per project, by reading the _NAME
    # variables
    for key, value in rawProjectData.items():
        # Keep only name keys (ending with _NAME, but not FOREGROUND_NAME nor
        # BACKGROUND_NAME)
        if not (key.endswith("_NAME") and not key.endswith("GROUND_NAME")):
            continue

        projectName = value
        projectPrefix = key.replace("_NAME", "")
        ALL_PROJECTS[projectName] = {"__prefix": projectPrefix}

    # Fill each entry with icon and colors
    for _, projectData in ALL_PROJECTS.items():
        projectPrefix = projectData["__prefix"]

        # Icon
        projectData["icon"] = rawProjectData.get(f"{projectPrefix}_ICON")

        # Background
        projectBgRaw = rawProjectData.get(f"{projectPrefix}_BACKGROUND", None)
        if projectBgRaw:
            projectData["bg"] = _oroshi_get_cursor_color(projectBgRaw)

        # Foreground
        projectFgRaw = rawProjectData.get(f"{projectPrefix}_FOREGROUND", None)
        if projectFgRaw:
            projectData["fg"] = _oroshi_get_cursor_color(projectFgRaw)


ALL_PROJECTS = {}
_oroshi_init_project_list()
# }}}


# On the first pass, we don't draw anything but gather all layout information
# about the tabs we'll draw in the second pass
# ALL_TABS {{{
def _oroshi_tab_first_pass(
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
    tabData = _oroshi_tab_data(tab, draw_data)
    tabTitleName = tabData["title"]
    tabTitleIcon = tabData["icon"]
    tabIsActive = tabData["isActive"]
    tabFg = tabData["fg"]
    tabBg = tabData["bg"]

    # Build the title with icon, name and potential full-screen icon
    tabTitle = f" {tabTitleIcon}{tabTitleName} "
    tabIsFullscreen = tabData["isFullscreen"]
    if tabIsFullscreen:
        tabTitle = f"{tabTitle} "

    # Also keep info about the next tab, for smoother separator transitions
    defaultBg = as_rgb(int(draw_data.default_bg))
    nextTabData = _oroshi_tab_data(extra_data.next_tab, draw_data)
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
        _oroshi_define_tabs_to_display(screen)


ALL_TABS = {}


# }}}


# Define the allowlist of tabs we want displayed, based on the available space
# TAB_ALLOWED_LIST {{{
def _oroshi_define_tabs_to_display(screen: Screen):
    global ALL_TABS
    global TAB_ALLOWED_LIST

    # Gathering metrics about the layout
    screenWidth = screen.columns
    statusBarWidth = _oroshi_get_statusbar_width()
    tabBarMaxWidth = screenWidth - statusBarWidth
    tabBarActualWidth = sum(_oroshi_tab_width(tab) for tab in ALL_TABS.values())

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
    activeTabIndex = _oroshi_get_active_tab_index()
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
        tabWidth = _oroshi_tab_width(tab)

        # Stop if we don't have space anymore
        if tabWidth > availableSpaceLeft:
            break

        TAB_ALLOWED_LIST.append(tabIndex)
        availableSpaceLeft -= tabWidth


# List of tab indexId that we can display (any tab that won't fit won't be added
# to this list)
TAB_ALLOWED_LIST = []
# }}}


# On the second pass, we have all the layout information, this is when we
# actually draw the tabs
# SECOND PASS {{{
def _oroshi_tab_second_pass(
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
        screen.draw("")

    # If last tab, also draw the status bar
    if is_last:
        _oroshi_draw_statusbar(screen)

    return screen.cursor.x


# }}}


# Returns a hash of useful data for a given tab
def _oroshi_tab_data(tab: TabBarData, draw_data: DrawData):  # {{{
    global ALL_PROJECTS

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
    projectData = ALL_PROJECTS.get(tabTitle, {})
    tabIcon = projectData.get("icon", "")

    tabData = {
        "title": tabTitle,
        "isFullscreen": tabIsFullscreen,
        "icon": tabIcon,
        "isActive": tabIsActive,
    }

    # Inactive tab, revert to default styles
    if not tabIsActive:
        tabData["fg"] = defaultInactiveFg
        tabData["bg"] = defaultInactiveBg
    # Active tab, use project colors if defined
    else:
        tabData["fg"] = projectData.get("fg", defaultActiveFg)
        tabData["bg"] = projectData.get("bg", defaultActiveBg)

    return tabData


# }}}
# Return the display width of a given tab, including space for the separator
def _oroshi_tab_width(tab):  # {{{
    separatorLength = 1
    return len(tab["title"]) + separatorLength


# }}}
# Return the currently active tab index
def _oroshi_get_active_tab_index():  # {{{
    global ALL_TABS
    for tab in ALL_TABS.values():
        if tab["isActive"]:
            return tab["index"]


# }}}
# }}}


# STATUSBAR {{{
# Update a specific statusbar part
# Works by running an external command, and updating the internal representation
#
# I previously used tmux, and had each part of the statusbar being built from
# a separate function. I converted those functions into statusbar-XXX scripts
# that now output JSON, to be more easily parsed by this script.
def _oroshi_statusbar_update(statusbarName: str):  # {{{
    # Path to the executable
    binName = f"statusbar-{statusbarName}"
    binPath = f"/home/tim/.oroshi/scripts/bin/statusbar/{binName}"

    # Convert raw JSON output to object
    rawOutput = subprocess.check_output(binPath)
    chunks = json.loads(rawOutput.decode())

    # Cast all fg/bg to expected format
    for chunk in chunks:
        if chunk.get("fg", None):
            chunk["fg"] = _oroshi_get_cursor_color(int(chunk["fg"]))
        if chunk.get("bg", None):
            chunk["bg"] = _oroshi_get_cursor_color(int(chunk["bg"]))

    # Update the representation of this part of statusbar
    STATUSBAR["items"][statusbarName]["chunks"] = chunks

    # Refresh the whole statusbar
    _oroshi_refresh_statusbar()


# }}}


# Init the STATUSBAR object
def _oroshi_init_statusbar():  # {{{
    global STATUSBAR
    global STATUSBAR_DEFINITION

    STATUSBAR = {"order": [], "items": {}}

    for item in STATUSBAR_DEFINITION:
        itemName, itemFrequency = item.split(":")
        itemFrequency = int(itemFrequency)

        # Add to the list
        STATUSBAR["order"].append(itemName)

        # Create an entry in items
        STATUSBAR["items"][itemName] = {
            "frequency": itemFrequency,
            "chunks": [],
        }

        # Update this specific statusbar part right now
        callback = lambda _=None, itemName=itemName: (  # noqa: E731
            _oroshi_statusbar_update(itemName),
        )
        callback()

        # And mark it to run again at a regular frequency
        add_timer(callback, itemFrequency, True)


STATUSBAR = {}
_oroshi_init_statusbar()
# }}}


# External tools can call kitty-refresh (which will create a beacon file)
# We will periodically check for this beacon, and if present refresh the
# statusbar
def _oroshi_check_for_forced_refresh(_=None):  # {{{
    beaconPath = "/home/tim/local/tmp/oroshi/kitty-refresh"

    # Nothing to do
    if not os.path.exists(beaconPath):
        return

    # We re-run all statusbar parts
    for itemName in STATUSBAR["order"]:
        _oroshi_statusbar_update(itemName)

    # We remove the beacon
    os.remove(beaconPath)


# Check for the beacon every 5s
add_timer(_oroshi_check_for_forced_refresh, 5, True)
# }}}


# Display the status bar
def _oroshi_draw_statusbar(screen: Screen):  # {{{
    global STATUSBAR

    # Position cursor at beginning of line
    statusbarWidth = _oroshi_get_statusbar_width()
    # Note: Putting a negative value here make kitty fail with a segfault, so we
    # keep it positive with max()
    screen.cursor.x = max(screen.cursor.x, screen.columns - statusbarWidth)

    # Write all statuses
    for itemName in STATUSBAR["order"]:
        itemData = STATUSBAR["items"][itemName]

        for itemChunk in itemData["chunks"]:
            chunkFg = itemChunk.get("fg", None)
            chunkBg = itemChunk.get("bg", None)
            chunkText = itemChunk.get("text", "")

            # Default coloring
            draw_attributed_string(Formatter.reset, screen)

            # Specific coloring
            if chunkFg:
                screen.cursor.fg = chunkFg
            if chunkBg:
                screen.cursor.bg = chunkBg
            # TODO: Add boldness

            screen.draw(chunkText)


# }}}


# Get the statusbar width, to correctly position it
def _oroshi_get_statusbar_width():  # {{{
    global STATUSBAR
    statusbarWidth = 0
    for itemName in STATUSBAR["order"]:
        itemData = STATUSBAR["items"][itemName]
        for itemChunk in itemData["chunks"]:
            statusbarWidth += len(itemChunk["text"])

    return statusbarWidth


# }}}


# Default kitty method called each time the statusbar needs to be displayed.
# Every print statement in this method is swallowed, so we'll call our own
# method instead for easier debugging.
def draw_tab(  # {{{
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    _oroshi_draw_tab(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )

    return screen.cursor.x


# Mirror of draw_tab. It is first called on all tabs with for_layout set to
# true, to gather all information. Then with for_layout set to false, to
# actually display something. We'll store information about the tabs in the
# first pass, and actually display them in the second pass
def _oroshi_draw_tab(  # {{{
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
        _oroshi_tab_first_pass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )
    else:
        _oroshi_tab_second_pass(
            draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
        )

    return screen.cursor.x


# }}}
