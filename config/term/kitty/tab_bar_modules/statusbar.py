import os
import json
import subprocess
from tab_bar_modules.projects import initProjectList
from kitty.boss import get_boss
from kitty.fast_data_types import Screen, add_timer
from kitty.tab_bar import Formatter, draw_attributed_string
from tab_bar_modules.colors import getCursorColor

statusbarState = {
    # List of items to display in the status bar.
    # Order is important, and number is the refresh delay (in seconds)
    # Note: use kitty-refresh script to force-refresh the display for debugging
    "manifest": [
        # "spotify:5",
        "sound-mode:60",
        "mic2txt-model:60",
        "battery:60",
        "cpu:30",
        "ram:30",
        # "ping:30",
        "clock:60",
        "dropbox:300",
    ],
    "order": [],
    "items": {},
}


# Init the STATUSBAR object
def initStatusbar():
    for item in statusbarState["manifest"]:
        itemName, itemFrequency = item.split(":")
        itemFrequency = int(itemFrequency)

        # Add to the list
        statusbarState["order"].append(itemName)

        # Create an entry in items
        statusbarState["items"][itemName] = {
            "frequency": itemFrequency,
            "chunks": [],
        }

        # Update this specific statusbar part right now
        callback = lambda _=None, itemName=itemName: (  # noqa: E731
            statusbarUpdate(itemName),
        )
        callback()

        # And mark it to run again at a regular frequency
        add_timer(callback, itemFrequency, True)

    # Check for the kitty-refresh beacon every 5s
    add_timer(lambda *_: checkForForcedRefresh(), 5, True)


# Mark the tab manager as dirty so Kitty will redraw it whenever it can
def refreshStatusbar():
    kittyTabManager = get_boss().active_tab_manager
    if kittyTabManager is not None:
        kittyTabManager.mark_tab_bar_dirty()


# Update a specific statusbar part
# Works by running an external command, and updating the internal representation
def statusbarUpdate(statusbarName: str):
    # Path to the executable
    binName = f"statusbar-{statusbarName}"
    binPath = f"/home/tim/.oroshi/scripts/bin/statusbar/{binName}"

    # Convert raw JSON output to object
    rawOutput = subprocess.check_output(binPath)
    chunks = json.loads(rawOutput.decode())

    # Cast all fg/bg to expected format
    for chunk in chunks:
        if chunk.get("fg", None):
            chunk["fg"] = getCursorColor(chunk["fg"])
        if chunk.get("bg", None):
            chunk["bg"] = getCursorColor(chunk["bg"])

    # Update the representation of this part of statusbar
    statusbarState["items"][statusbarName]["chunks"] = chunks

    # Refresh the whole statusbar
    refreshStatusbar()


# External tools can call kitty-refresh (which will create a beacon file)
# We will periodically check for this beacon, and if present refresh the
# statusbar
def checkForForcedRefresh():
    beaconPath = "/home/tim/local/tmp/oroshi/kitty-refresh"

    # Nothing to do
    if not os.path.exists(beaconPath):
        return

    # Reload ALL_PROJECTS to get updated project colors
    initProjectList()

    # We re-run all statusbar parts
    for itemName in statusbarState["order"]:
        statusbarUpdate(itemName)

    # Explicitly mark tab bar as dirty to force redraw
    refreshStatusbar()

    # We remove the beacon
    os.remove(beaconPath)


# Display the status bar
def drawStatusbar(screen: Screen):
    # Position cursor at beginning of line
    statusbarWidth = getStatusbarWidth()
    # Note: Putting a negative value here make kitty fail with a segfault, so we
    # keep it positive with max()
    screen.cursor.x = max(screen.cursor.x, screen.columns - statusbarWidth)

    # Write all statuses
    for itemName in statusbarState["order"]:
        itemData = statusbarState["items"][itemName]

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
def getStatusbarWidth():
    statusbarWidth = 0
    for itemName in statusbarState["order"]:
        itemData = statusbarState["items"][itemName]
        for itemChunk in itemData["chunks"]:
            statusbarWidth += len(itemChunk["text"])

    return statusbarWidth
