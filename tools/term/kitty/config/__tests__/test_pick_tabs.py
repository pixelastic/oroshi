import pytest
from unittest.mock import MagicMock

import lib.pick_tabs as pick_tabs
from lib.state import tabState

# Width 53 per tab (len 52 + separator 1).
# Using wide tabs avoids the min-50 floor triggering all-fits when testing overflow.
TAB = "X" * 52
TAB_WIDTH = 53

# Width 10 per tab — used for narrow-tab tests
NARROW = "X" * 9
NARROW_WIDTH = 10


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["displayedTabIds"] = []
    tabState["notificationIds"] = set()
    yield


def _setup_tabs(titles, active_index_1based):
    tabState["allTabIds"] = list(range(1, len(titles) + 1))
    for i, title in enumerate(titles):
        tab_id = i + 1
        tabState["manifest"][tab_id] = {
            "title": title,
            "isActive": tab_id == active_index_1based,
            "index": tab_id,
        }


def _make_screen(columns):
    screen = MagicMock()
    screen.columns = columns
    return screen


# --- get_tab_width ---


def test_get_tab_width_returns_title_length_plus_one():
    _setup_tabs(["hello"], active_index_1based=1)
    assert pick_tabs.get_tab_width(1) == 6  # len("hello") + 1


# --- get_full_tab_bar_width ---


def test_get_full_tab_bar_width_sums_all_tab_widths():
    _setup_tabs(["ab", "cde", "f"], active_index_1based=1)
    # widths: 3, 4, 2 → total 9
    assert pick_tabs.get_full_tab_bar_width() == 9


# --- get_active_tab_index ---


def test_get_active_tab_index_returns_index_of_active_tab():
    _setup_tabs(["a", "b", "c"], active_index_1based=2)
    assert pick_tabs.get_active_tab_index() == 2


# --- pick_tabs_to_display: all fits ---


def test_pick_tabs_all_fit_displays_all_tabs():
    _setup_tabs([TAB, TAB, TAB], active_index_1based=2)
    # total=159, budget=200 → 159 ≤ 200, all fit
    pick_tabs.pick_tabs_to_display(_make_screen(200))
    assert tabState["displayedTabIds"] == tabState["allTabIds"]


# --- pick_tabs_to_display: overflow, priority order ---


def test_pick_tabs_active_included_first_when_budget_tight():
    # 5 tabs width 53, budget=53 → exactly 1 tab fits, must be active
    _setup_tabs([TAB] * 5, active_index_1based=3)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH))
    assert tabState["displayedTabIds"] == [3]


def test_pick_tabs_active_plus_one_before_active_minus_one():
    # 5 tabs width 53, budget=106 → 2 tabs fit: active then active+1, not active-1
    _setup_tabs([TAB] * 5, active_index_1based=3)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 2))
    assert tabState["displayedTabIds"] == [3, 4]


def test_pick_tabs_active_minus_one_before_tabs_further_before():
    # 5 tabs width 53, budget=159 → 3 tabs fit: active, active+1, active-1 (not active-2)
    _setup_tabs([TAB] * 5, active_index_1based=3)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 3))
    assert tabState["displayedTabIds"] == [3, 4, 2]


def test_pick_tabs_further_before_closest_to_furthest():
    # 6 tabs, active at 4, budget=212 → 4 fit: active, active+1, active-1, active-2
    _setup_tabs([TAB] * 6, active_index_1based=4)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 4))
    assert tabState["displayedTabIds"] == [4, 5, 3, 2]


def test_pick_tabs_further_after_closest_to_furthest():
    # 7 tabs, active at 2, budget=265 → 5 fit: active, active+1, active-1, active+2, active+3
    _setup_tabs([TAB] * 7, active_index_1based=2)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 5))
    assert tabState["displayedTabIds"] == [2, 3, 1, 4, 5]


# --- pick_tabs_to_display: budget ---


def test_pick_tabs_stops_when_next_tab_exceeds_remaining_space():
    # active fits (rem=7), next tab in priority needs 53 → break; a later narrow tab (width=10)
    # is never reached, confirming break (not continue) semantics
    # Tabs: wide, wide, wide, wide, narrow — active at 3
    _setup_tabs([TAB, TAB, TAB, TAB, NARROW], active_index_1based=3)
    # budget=60: tab 3 width 53 fits (rem 7), tab 4 width 53 > 7 → break
    # tab 5 (NARROW, width 10) would fit but iteration stopped
    pick_tabs.pick_tabs_to_display(_make_screen(60))
    assert tabState["displayedTabIds"] == [3]


def test_pick_tabs_tab_that_fits_included_when_earlier_position_is_oob():
    # active at last index: active+1 is OOB → skipped with continue, not break
    # active-1 is still evaluated and added if it fits
    # 3 tabs, active=3, width 53, budget=113: tab 3 (rem 60), pos 4 OOB skip,
    # tab 2 (rem 7), tab 1: 53>7 break → [3, 2]
    _setup_tabs([TAB] * 3, active_index_1based=3)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 2 + 7))
    assert tabState["displayedTabIds"] == [3, 2]


# --- pick_tabs_to_display: bounds ---


def test_pick_tabs_position_zero_is_skipped():
    # active at index 1: active-1=0 appears in priority list → OOB, skipped
    # iteration continues: tab at active+2 is still evaluated
    # 3 tabs, active=1, width 53, budget=113: tab 1 (rem 60), tab 2 (rem 7),
    # pos 0 skip, tab 3: 53>7 break → [1, 2]
    _setup_tabs([TAB] * 3, active_index_1based=1)
    pick_tabs.pick_tabs_to_display(_make_screen(TAB_WIDTH * 2 + 7))
    assert tabState["displayedTabIds"] == [1, 2]
