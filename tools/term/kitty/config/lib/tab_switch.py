from kitty.fast_data_types import add_timer

from lib.state import tabState

# List of callbacks to fire (guarded to survive module reload)
if "_listeners" not in globals():
    _listeners = []
# Last active tab seen by check()
_last_tab_id = None


CALLBACK_DELAY = 2.0


# Register a callback (deduplicate on reload)
def on_tab_switch(callback):
    for listener in _listeners:
        if listener["callback"] is callback:
            return
    _listeners.append({"callback": callback, "counter": 0})


# Called once per render cycle. Fires registered callbacks only when the active
# tab has changed since the last check.
def check():
    global _last_tab_id

    # Return early if this redraw hasn't switch tabs.
    activeTabId = str(tabState["activeTabId"])
    if activeTabId == _last_tab_id:
        return
    _last_tab_id = activeTabId

    # Fire all listeners
    for listener in _listeners:
        listener["counter"] += 1
        context = {
            "listener": listener,
            "counter": listener["counter"],
        }

        def _on_timer(*_, context=context):
            # Return early if the listener is stale (its counter now is
            # different from the counter when it was set)
            if context["counter"] != context["listener"]["counter"]:
                return

            context["listener"]["callback"](activeTabId)

        add_timer(_on_timer, CALLBACK_DELAY, False)
