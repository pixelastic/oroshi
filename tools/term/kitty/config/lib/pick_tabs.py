from kitty.fast_data_types import Screen
from lib.tabs import tabState
from lib.statusbar import get_statusbar_width

# This is based on the length of the  character used as a separator
SEPARATOR_LENGTH = 1


# Define the allowlist of tabs we want displayed, based on the available space
def pick_tabs_to_display(screen: Screen):
    # Gathering metrics about the layout
    screen_width = screen.columns
    status_bar_width = get_statusbar_width()
    # Even with a large statusbar, we still want at least 50 chars for the tabs
    tab_bar_max_width = max(screen_width - status_bar_width, 50)
    tab_bar_actual_width = get_full_tab_bar_width()

    # If everything fits, we keep all tabs
    if tab_bar_actual_width <= tab_bar_max_width:
        tabState["displayedTabIds"] = tabState["allTabIds"]
        return

    # We define which tabs we want to keep, by order of priority
    active_tab_index = get_active_tab_index()
    tab_count = len(tabState["allTabIds"])
    all_tabs_before = list(range(active_tab_index - 2, 0, -1))
    all_tabs_after = list(range(active_tab_index + 2, tab_count + 1))
    positions_of_tabs_to_keep = [
        active_tab_index,  # The active tab
        active_tab_index + 1,  # The tab after the active one
        active_tab_index - 1,  # The tab before the active one
        *(all_tabs_before),  # All tabs before, from closest to furthest
        *(all_tabs_after),  # All tabs after, from closest to furthest
    ]

    # We will iterate through our list of tabs to keep,
    # until we run out of space
    available_space_left = tab_bar_max_width
    displayed_tab_ids = []
    for tab_position in positions_of_tabs_to_keep:
        # Note: tab_position is a kitty-index (1-based),
        # while allTabIds is a python array (0-based).

        # Exclude positions out of bounds
        if tab_position <= 0 or tab_position > tab_count:
            continue

        # Find the tab width
        # Note: We convert kitty position to python index to metadata
        tab_id = tabState["allTabIds"][tab_position - 1]
        tab_width = get_tab_width(tab_id)

        # Stop if we don't have space anymore
        if tab_width > available_space_left:
            break

        displayed_tab_ids.append(tab_id)
        available_space_left -= tab_width

    tabState["displayedTabIds"] = displayed_tab_ids


# Returns the width of a given tab
def get_tab_width(tab_id):
    return len(tabState["manifest"][tab_id]["title"]) + SEPARATOR_LENGTH


# Returns the full tabBar width if we display all tabs
def get_full_tab_bar_width():
    total_width = 0
    for tab_id in tabState["allTabIds"]:
        total_width += get_tab_width(tab_id)
    return total_width


# Return the currently active tab index
def get_active_tab_index():
    for tab_id in tabState["allTabIds"]:
        tab_data = tabState["manifest"][tab_id]
        if tab_data["isActive"]:
            return tab_data["index"]
