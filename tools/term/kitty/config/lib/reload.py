import importlib
import sys
from lib import files

RELOAD_BEACON = "/home/tim/local/tmp/oroshi/kitty/beacons/reload"
MODULE_REL_PATH = "tools/term/kitty/config/lib"


def check():
    # Stop early if no beacon
    if not files.exists(RELOAD_BEACON):
        return

    # Read source path from the beacon
    source_root = files.read(RELOAD_BEACON).strip()

    # Point lib's __path__ at the source so new modules can be found on import
    sys.modules["lib"].__path__ = [f"{source_root}/{MODULE_REL_PATH}"]

    # Reload all lib.* modules from the beacon path
    for name, module in list(sys.modules.items()):
        if not name.startswith("lib."):
            continue
        importlib.reload(module)

    # Delete beacon after successful loading
    files.remove(RELOAD_BEACON)

    # Re-run init functions to refresh in-memory state
    sys.modules["lib.projects"].init()
    sys.modules["lib.tab_data"].init()
