from kitty.boss import get_boss
from kitty.fast_data_types import add_timer

from lib import files
from lib.state import tabState

# Whenever we redraw the tab bar, we check if we need to clear any attention
# icon. This is effectively only needed when we switch tabs, not for any other
# redraw
# Last tab ID we scheduled a timer for — avoids duplicate timers on same tab
_attention_callback_tab_id = None

# Whenever we switch tabs, we fire a delayed callback (~2s). If we're still on
# the same tab when the callback fires, then we clear the attention icon
# automatically.
# Kitty uses its own add_timer mechanism for callback, and there is no way to
# cancel a timer once it's started, so whenever we switch tabs, timers
# accumulates. We're only interested in the very last callback, so we use a
# callback_counter to differenciate them and no-op stale callbacks.
_attention_callback_counter = 0

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"
ATTENTION_CLEAR_DELAY = 2.0


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


# Called once per render cycle (on the last tab). Schedules a kitty timer to
# clear the active tab's attention after a delay. Uses kitty's add_timer (event
# loop) instead of threading.Timer, because kitty holds the GIL between render
# cycles and Python Timer threads cannot fire on idle tabs.
def schedule_attention_clear():
    global _attention_callback_counter, _attention_callback_tab_id

    active_tab_id = str(tabState["activeTabId"])

    # Same tab — timer already scheduled, nothing to do
    if active_tab_id == _attention_callback_tab_id:
        return

    # Tab changed — invalidate previous timer and schedule a new one
    _attention_callback_counter += 1
    gen = _attention_callback_counter
    _attention_callback_tab_id = active_tab_id

    def _on_timer(*_):
        # Stale callback — a newer tab switch superseded this one
        if gen != _attention_callback_counter:
            return
        _clear_attention(active_tab_id)

    add_timer(_on_timer, ATTENTION_CLEAR_DELAY, False)


def _clear_attention(tab_id):
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
