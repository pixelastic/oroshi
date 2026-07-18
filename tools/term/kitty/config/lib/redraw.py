from kitty.boss import get_boss

from lib import files
from lib.state import tabState
from lib.tab_switch import on_tab_switch

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


def check():
    # Stop early if no beacon
    if not files.exists(REDRAW_BEACON):
        return

    # Error, beacon but no attention file
    if not files.exists(ATTENTION_FILE):
        tabState["attentionIds"] = {}
        files.remove(REDRAW_BEACON)
        return

    # Update the attention list
    ids = {}
    for line in files.read(ATTENTION_FILE).splitlines():
        line = line.strip()
        if not line:
            continue
        tab_id, attention_type = line.split(":", 1)
        ids[tab_id] = attention_type
    tabState["attentionIds"] = ids
    files.remove(REDRAW_BEACON)


def cleanup():
    live_tab_ids = tabState["allTabIds"]

    # Prune manifest entries for tabs that no longer exist
    stale_ids = [k for k in tabState["manifest"] if k not in live_tab_ids]
    for k in stale_ids:
        del tabState["manifest"][k]

    # Reset allTabIds so first_pass can rebuild it next cycle
    tabState["allTabIds"] = []

    # Now, update the attention file on disk to remove any stale entries (for
    # example if we removed a tab)
    if not files.exists(ATTENTION_FILE):
        return

    # Parse attention file into non-empty lines (each line is "tabId:type")
    lines = [line for line in files.read(ATTENTION_FILE).splitlines() if line.strip()]

    # Keep only entries whose tab ID still exists
    live_strings = {str(tid) for tid in live_tab_ids}
    kept = [entry for entry in lines if entry.split(":", 1)[0] in live_strings]

    # Nothing stale
    if len(kept) == len(lines):
        return

    # Rewrite the attention file without stale entries
    files.write(ATTENTION_FILE, "\n".join(kept) + "\n" if kept else "")


# Remove any attention icon when we stay on a tab for a while
def clear_attention(tab_id):
    if not files.exists(ATTENTION_FILE):
        return

    lines = files.read(ATTENTION_FILE).splitlines()
    kept = [
        line for line in lines if line.strip() and not line.startswith(f"{tab_id}:")
    ]

    # Nothing to remove
    if len(kept) == len([line for line in lines if line.strip()]):
        return

    files.write(ATTENTION_FILE, "\n".join(kept) + "\n" if kept else "")
    tabState["attentionIds"].pop(tab_id, None)

    # Force kitty to repaint the tab bar
    tab_manager = get_boss().active_tab_manager
    if tab_manager is not None:
        tab_manager.mark_tab_bar_dirty()


# Register the callback
on_tab_switch(clear_attention)
