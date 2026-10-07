from unittest.mock import MagicMock

import lib.redraw as redraw
import lib.tab_switch as tab_switch
import lib.tabs_first_pass as tabs_first_pass
import lib.tabs_second_pass as tabs_second_pass
import pytest
from lib.state import tabState

# Tab ID that build_tab_data reports as active
_focus = {"tab_id": None}


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["displayedTabIds"] = []
    tabState["notificationIds"] = set()
    tabState["activeTabId"] = None
    tab_switch._listeners = []
    tab_switch._last_tab_id = None
    tab_switch.on_tab_switch(redraw.clear_notification)
    yield


@pytest.fixture(autouse=True)
def patch_paths(mocker, tmp_path):
    beacon_dir = tmp_path / "beacons"
    beacon_dir.mkdir()
    mocker.patch.object(redraw, "REDRAW_BEACON", str(beacon_dir / "redraw"))
    mocker.patch.object(redraw, "NOTIFICATION_FILE", str(tmp_path / "notification"))
    mocker.patch("lib.redraw.get_boss")
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch(
        "lib.tabs_first_pass.build_tab_data",
        side_effect=lambda tab, _draw_data: {
            "id": tab.tab_id,
            "isActive": tab.tab_id == _focus["tab_id"],
            "fg": 0,
            "bg": 0,
            "title": f"tab-{tab.tab_id}",
            "notificationMarker": "",
            "separatorBg": 0,
            "separatorFg": 0,
        },
    )
    mocker.patch(
        "lib.tabs_first_pass.pick_tabs_to_display",
        side_effect=lambda _screen: tabState.update(
            displayedTabIds=list(tabState["allTabIds"])
        ),
    )
    yield


@pytest.fixture
def add_timer(mocker):
    return mocker.patch("lib.tab_switch.add_timer")


def _tab(tab_id):
    tab = MagicMock()
    tab.tab_id = tab_id
    return tab


def _layout_pass(tab_ids, focused):
    _focus["tab_id"] = focused
    for position, tab_id in enumerate(tab_ids, start=1):
        extra_data = MagicMock()
        extra_data.next_tab = None
        tabs_first_pass.first_pass(
            MagicMock(),
            MagicMock(),
            _tab(tab_id),
            0,
            10,
            position,
            position == len(tab_ids),
            extra_data,
        )


def _draw_pass(tab_ids, stop_before=None):
    screen = MagicMock()
    drawn = []
    for position, tab_id in enumerate(tab_ids, start=1):
        if tab_id == stop_before:
            return drawn
        screen.draw.reset_mock()
        tabs_second_pass.second_pass(
            MagicMock(),
            screen,
            _tab(tab_id),
            0,
            10,
            position,
            position == len(tab_ids),
            MagicMock(),
        )
        if screen.draw.called:
            drawn.append(tab_id)
    return drawn


def _write_beacon():
    open(redraw.REDRAW_BEACON, "w").close()


def _write_notifications(*tab_ids):
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("".join(f"{tab_id}\n" for tab_id in tab_ids))


def _read_notifications():
    with open(redraw.NOTIFICATION_FILE) as f:
        return f.read().split()


# --- Cut-short draw pass (Kitty never draws the last tab) ---


def test_active_tab_recorded_when_draw_pass_never_reaches_it(add_timer):
    _layout_pass([1, 2, 3], focused=3)
    _draw_pass([1, 2, 3], stop_before=3)

    assert tabState["activeTabId"] == 3


def test_tab_switch_callback_fires_when_draw_pass_stops_before_last_tab(add_timer):
    _layout_pass([1, 2, 3], focused=3)
    _draw_pass([1, 2, 3], stop_before=3)

    add_timer.assert_called_once()
    add_timer.call_args[0][0]()
    assert tab_switch._last_tab_id == "3"


def test_marker_clears_two_seconds_after_focusing_tab_with_cut_short_draw(add_timer):
    _write_notifications(3)
    tabState["notificationIds"] = {"3"}

    _layout_pass([1, 2, 3], focused=3)
    _draw_pass([1, 2, 3], stop_before=3)
    add_timer.call_args[0][0]()

    assert tabState["notificationIds"] == set()
    assert _read_notifications() == []


def test_redraw_beacon_consumed_on_next_cycle_after_cut_short_draw_pass(add_timer):
    _layout_pass([1, 2, 3], focused=1)
    _draw_pass([1, 2, 3], stop_before=3)
    _write_beacon()
    _write_notifications(2)

    _layout_pass([1, 2, 3], focused=1)
    _draw_pass([1, 2, 3], stop_before=3)

    assert not redraw.files.exists(redraw.REDRAW_BEACON)
    assert tabState["notificationIds"] == {"2"}


def test_closed_tabs_leave_notification_tab_list_after_cut_short_draw(add_timer):
    _write_notifications(1, 2, 3)
    tabState["notificationIds"] = {"1", "2", "3"}

    _layout_pass([1, 3], focused=1)
    _draw_pass([1, 3], stop_before=3)

    assert _read_notifications() == ["1", "3"]
    assert tabState["notificationIds"] == {"1", "3"}


def test_closed_tabs_leave_manifest_after_cut_short_draw(add_timer):
    _layout_pass([1, 2, 3], focused=1)
    _layout_pass([1, 3], focused=1)

    assert sorted(tabState["manifest"]) == [1, 3]


# --- Normal draw pass ---


def test_switch_shorter_than_two_seconds_keeps_notification_marker(add_timer):
    _write_notifications(2)
    tabState["notificationIds"] = {"2"}

    _layout_pass([1, 2], focused=2)
    focus_two_timer = add_timer.call_args[0][0]
    _layout_pass([1, 2], focused=1)
    focus_two_timer()

    assert tabState["notificationIds"] == {"2"}
    assert _read_notifications() == ["2"]


def test_all_tabs_drawn_when_all_displayed(add_timer):
    _layout_pass([1, 2, 3], focused=2)

    assert _draw_pass([1, 2, 3]) == [1, 2, 3]


def test_cycle_state_survives_the_draw_pass(add_timer):
    _layout_pass([1, 2, 3], focused=2)
    _draw_pass([1, 2, 3])

    assert tabState["allTabIds"] == [1, 2, 3]
    assert tabState["activeTabId"] == 2


def test_layout_pass_twice_in_one_update_adds_no_duplicate_tab_ids(add_timer):
    _layout_pass([1, 2, 3], focused=2)
    _layout_pass([1, 2, 3], focused=2)

    assert tabState["allTabIds"] == [1, 2, 3]
    add_timer.assert_called_once()
