import importlib
import sys
from lib import files

RELOAD_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/reload"


def check():
    # Stop early if no beacon
    if not files.exists(RELOAD_BEACON):
        return

    # Delete beacon first to prevent double-trigger
    files.remove(RELOAD_BEACON)

    # Reload all lib.* modules currently loaded
    for name, module in list(sys.modules.items()):
        if name.startswith("lib."):
            importlib.reload(module)

    # Re-run init functions to refresh in-memory state
    sys.modules["lib.projects"].init()
    sys.modules["lib.tab_data"].init()
