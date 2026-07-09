import importlib
import sys

TAB_BAR_MODULES = [
    "lib.colors",
    "lib.helper",
    "lib.projects",
    "lib.tabs",
    "lib.tab_data",
    "lib.pick_tabs",
    "lib.tabs_first_pass",
    "lib.tabs_second_pass",
    "lib.statusbar",
]


def reload_tab_bar():
    # Invalidate old timer callbacks before reloading
    if "lib.statusbar" in sys.modules:
        sys.modules["lib.statusbar"]._generation += 1

    for name in TAB_BAR_MODULES:
        if name in sys.modules:
            importlib.reload(sys.modules[name])

    sys.modules["lib.projects"].init()
    sys.modules["lib.statusbar"].init()
