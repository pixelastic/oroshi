import os
from lib.state import tabState

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


def check():
    # Stop early if no beacon
    if not os.path.exists(REDRAW_BEACON):
        return

    # Error, beacon but no attention file
    if not os.path.exists(ATTENTION_FILE):
        tabState["attentionIds"] = {}
        os.remove(REDRAW_BEACON)
        return

    # Update the attention list
    with open(ATTENTION_FILE) as f:
        ids = {}
        for line in f:
            line = line.strip()
            if not line:
                continue
            tab_id, attention_type = line.split(":", 1)
            ids[tab_id] = attention_type
        tabState["attentionIds"] = ids
        os.remove(REDRAW_BEACON)
