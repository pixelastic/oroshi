from kitty.boss import get_boss

from lib import files
from lib.state import tabState
from lib.tab_switch import on_tab_switch

REDRAW_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/redraw"
NOTIFICATION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


# Sync notification file into tabState when a redraw beacon is present
def check():
    # Stop early if no beacon
    if not files.exists(REDRAW_BEACON):
        return

    entries = _read_notification_entries()

    # Error, beacon but no notification file
    if entries is None:
        tabState["notificationIds"] = set()
        files.remove(REDRAW_BEACON)
        return

    # Update the notification list state
    # COMPAT: remove when ZSH functions no longer write tabId:type
    ids = set()
    for line in entries:
        tab_id = line.split(":", 1)[0]
        ids.add(tab_id)
    tabState["notificationIds"] = ids

    # Remove beacon
    files.remove(REDRAW_BEACON)


# Prune stale tabs from manifest and notification file
def cleanup():
    live_tab_ids = tabState["allTabIds"]

    # Prune manifest entries for tabs that no longer exist
    stale_ids = [k for k in tabState["manifest"] if k not in live_tab_ids]
    for k in stale_ids:
        del tabState["manifest"][k]

    # Reset allTabIds so first_pass can rebuild it next cycle
    tabState["allTabIds"] = []

    # Remove notification entries for closed tabs
    live_strings = {str(tid) for tid in live_tab_ids}
    _remove_notification_entries(lambda tid: tid in live_strings)


# Remove notification marker when we stay on a tab for a while
def clear_notification(tab_id):
    tab_id_str = str(tab_id)
    if not _remove_notification_entries(lambda tid: tid != tab_id_str):
        return

    # Force kitty to repaint the tab bar
    tab_manager = get_boss().active_tab_manager
    tab_manager.mark_tab_bar_dirty()


# Register the callback
on_tab_switch(clear_notification)


# Re-read the notification file and parse into lines
def _read_notification_entries():
    if not files.exists(NOTIFICATION_FILE):
        return None
    return [line for line in files.read(NOTIFICATION_FILE).splitlines() if line.strip()]


# Remove entries from disk and memory based on a keep predicate.
# Returns True when in-memory state changed (= repaint needed).
def _remove_notification_entries(keep):
    # Disk: best-effort
    entries = _read_notification_entries()
    if entries is not None:
        # COMPAT: remove when ZSH functions no longer write tabId:type
        kept = [e for e in entries if keep(e.split(":", 1)[0])]
        if len(kept) != len(entries):
            files.write(NOTIFICATION_FILE, "\n".join(kept) + "\n" if kept else "")

    # Memory: authoritative
    stale = [k for k in tabState["notificationIds"] if not keep(k)]
    for k in stale:
        tabState["notificationIds"].discard(k)

    return len(stale) > 0
