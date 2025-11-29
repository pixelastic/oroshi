import os
import json
import subprocess
from kitty.boss import get_boss
from kitty.fast_data_types import (
    Screen,
    add_timer,
    get_options,
)
from kitty.tab_bar import (
    Formatter,
    draw_attributed_string,
)
from tab_bar_modules.colors import getCursorColor


# Mark the tab manager as dirty so Kitty will redraw it whenever it can
def refreshStatusbar():
    kittyTabManager = get_boss().active_tab_manager
    if kittyTabManager is not None:
        kittyTabManager.mark_tab_bar_dirty()


# Update a specific statusbar part
# Works by running an external command, and updating the internal representation
#
# I previously used tmux, and had each part of the statusbar being built from
# a separate function. I converted those functions into statusbar-XXX scripts
# that now output JSON, to be more easily parsed by this script.
def statusbarUpdate(statusbarName: str, statusbar: dict):
    # Path to the executable
    binName = f"statusbar-{statusbarName}"
    binPath = f"/home/tim/.oroshi/scripts/bin/statusbar/{binName}"

    # Convert raw JSON output to object
    rawOutput = subprocess.check_output(binPath)
    chunks = json.loads(rawOutput.decode())

    # Cast all fg/bg to expected format
    for chunk in chunks:
        if chunk.get("fg", None):
            chunk["fg"] = getCursorColor(int(chunk["fg"]))
        if chunk.get("bg", None):
            chunk["bg"] = getCursorColor(int(chunk["bg"]))

    # Update the representation of this part of statusbar
    statusbar["items"][statusbarName]["chunks"] = chunks

    # Refresh the whole statusbar
    refreshStatusbar()


# Init the STATUSBAR object
def initStatusbar(statusbarDefinition: list):
    statusbar = {"order": [], "items": {}}

    for item in statusbarDefinition:
        itemName, itemFrequency = item.split(":")
        itemFrequency = int(itemFrequency)

        # Add to the list
        statusbar["order"].append(itemName)

        # Create an entry in items
        statusbar["items"][itemName] = {
            "frequency": itemFrequency,
            "chunks": [],
        }

        # Update this specific statusbar part right now
        callback = lambda _=None, itemName=itemName: (  # noqa: E731
            statusbarUpdate(itemName, statusbar),
        )
        callback()

        # And mark it to run again at a regular frequency
        add_timer(callback, itemFrequency, True)

    return statusbar


# External tools can call kitty-refresh (which will create a beacon file)
# We will periodically check for this beacon, and if present refresh the
# statusbar
def checkForForcedRefresh(statusbar: dict, initProjectListCallback):
    beaconPath = "/home/tim/local/tmp/oroshi/kitty-refresh"

    # Nothing to do
    if not os.path.exists(beaconPath):
        return

    # Reload KITTY_OPTIONS to get updated colors from colors.conf
    global KITTY_OPTIONS
    KITTY_OPTIONS = get_options()

    # Reload ALL_PROJECTS to get updated project colors
    initProjectListCallback()

    # We re-run all statusbar parts
    for itemName in statusbar["order"]:
        statusbarUpdate(itemName, statusbar)

    # Explicitly mark tab bar as dirty to force redraw
    refreshStatusbar()

    # We remove the beacon
    os.remove(beaconPath)


# Display the status bar
def drawStatusbar(screen: Screen, statusbar: dict):
    # Position cursor at beginning of line
    statusbarWidth = getStatusbarWidth(statusbar)
    # Note: Putting a negative value here make kitty fail with a segfault, so we
    # keep it positive with max()
    screen.cursor.x = max(screen.cursor.x, screen.columns - statusbarWidth)

    # Write all statuses
    for itemName in statusbar["order"]:
        itemData = statusbar["items"][itemName]

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


# Get the statusbar width, to correctly position it
def getStatusbarWidth(statusbar: dict):
    statusbarWidth = 0
    for itemName in statusbar["order"]:
        itemData = statusbar["items"][itemName]
        for itemChunk in itemData["chunks"]:
            statusbarWidth += len(itemChunk["text"])

    return statusbarWidth
