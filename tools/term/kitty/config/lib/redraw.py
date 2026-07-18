from kitty.boss import get_boss

from lib import files
from lib.state import tabState
from lib.tab_switch import on_tab_switch

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


# Sync attention file into tabState when a redraw beacon is present
def check():
    # Stop early if no beacon
    if not files.exists(REDRAW_BEACON):
        return

    entries = _read_attention_entries()

    # Error, beacon but no attention file
    if entries is None:
        tabState["attentionIds"] = {}
        files.remove(REDRAW_BEACON)
        return

    # Update the attention list state
    ids = {}
    for line in entries:
        tab_id, attention_type = line.split(":", 1)
        ids[tab_id] = attention_type
    tabState["attentionIds"] = ids

    # Remove beacon
    files.remove(REDRAW_BEACON)


# Prune stale tabs from manifest and attention file
def cleanup():
    live_tab_ids = tabState["allTabIds"]

    # Prune manifest entries for tabs that no longer exist
    stale_ids = [k for k in tabState["manifest"] if k not in live_tab_ids]
    for k in stale_ids:
        del tabState["manifest"][k]

    # Reset allTabIds so first_pass can rebuild it next cycle
    tabState["allTabIds"] = []

    # Remove attention entries for closed tabs
    live_strings = {str(tid) for tid in live_tab_ids}
    _remove_attention_entries(lambda tid: tid in live_strings)


# Remove any attention icon when we stay on a tab for a while
def clear_attention(tab_id):
    tab_id_str = str(tab_id)
    if not _remove_attention_entries(lambda tid: tid != tab_id_str):
        return

    tabState["attentionIds"].pop(tab_id, None)

    # Force kitty to repaint the tab bar
    tab_manager = get_boss().active_tab_manager
    tab_manager.mark_tab_bar_dirty()


# Register the callback
on_tab_switch(clear_attention)


# Re-read the attention file and parse into tabId:type lines
def _read_attention_entries():
    if not files.exists(ATTENTION_FILE):
        return None
    return [line for line in files.read(ATTENTION_FILE).splitlines() if line.strip()]


# Remove lines from the attention file based on a callback
def _remove_attention_entries(keep):
    entries = _read_attention_entries()
    if entries is None:
        return False

    kept = [e for e in entries if keep(e.split(":", 1)[0])]
    if len(kept) == len(entries):
        return False

    files.write(ATTENTION_FILE, "\n".join(kept) + "\n" if kept else "")
    return True
