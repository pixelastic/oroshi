import os
from lib.tabs import tabState

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


def check():
    # Stop early if no beacon
    if not os.path.exists(REDRAW_BEACON):
        return

    # Error, beacon but no attention file
    if not os.path.exists(ATTENTION_FILE):
        tabState["attentionIds"] = set()
        os.remove(REDRAW_BEACON)
        return

    # Update the attention list
    with open(ATTENTION_FILE) as f:
        tabState["attentionIds"] = {line.strip() for line in f if line.strip()}
        os.remove(REDRAW_BEACON)
