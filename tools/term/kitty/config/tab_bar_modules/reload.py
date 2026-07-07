import importlib
import sys

TAB_BAR_MODULES = [
    "tab_bar_modules.colors",
    "tab_bar_modules.helper",
    "tab_bar_modules.projects",
    "tab_bar_modules.tabs",
    "tab_bar_modules.parseRawTabData",
    "tab_bar_modules.pickTabsToDisplay",
    "tab_bar_modules.tabs_first_pass",
    "tab_bar_modules.tabs_second_pass",
    "tab_bar_modules.statusbar",
]


def reloadTabBar():
    # Invalidate old timer callbacks before reloading
    if "tab_bar_modules.statusbar" in sys.modules:
        sys.modules["tab_bar_modules.statusbar"]._generation += 1

    for name in TAB_BAR_MODULES:
        if name in sys.modules:
            importlib.reload(sys.modules[name])

    sys.modules["tab_bar_modules.projects"].init_project_list()
    sys.modules["tab_bar_modules.statusbar"].init_statusbar()
