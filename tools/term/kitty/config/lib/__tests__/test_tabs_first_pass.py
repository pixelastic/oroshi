from unittest.mock import MagicMock

import lib.tabs_first_pass as tabs_first_pass
import pytest
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["displayedTabIds"] = []
    tabState["notificationIds"] = set()
    tabState["activeTabId"] = None
    yield


def _make_args(index=1, is_last=False, next_tab=None):
    extra_data = MagicMock()
    extra_data.next_tab = next_tab
    return (MagicMock(), MagicMock(), MagicMock(), 0, 10, index, is_last, extra_data)


# --- Reload Beacon / Redraw Beacon: timing ---


def test_reload_check_called_on_first_invocation(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mock_reload = mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())

    mock_reload.assert_called_once()


def test_redraw_check_called_on_first_invocation(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mock_redraw = mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())

    mock_redraw.assert_called_once()


def test_reload_check_called_before_redraw_check(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    call_order = []
    mocker.patch(
        "lib.tabs_first_pass.reload.check",
        side_effect=lambda: call_order.append("reload"),
    )
    mocker.patch(
        "lib.tabs_first_pass.redraw.check",
        side_effect=lambda: call_order.append("redraw"),
    )

    tabs_first_pass.first_pass(*_make_args())

    assert call_order == ["reload", "redraw"]


def test_reload_and_redraw_beacon_checks_not_called_on_subsequent_tab(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mock_reload = mocker.patch("lib.tabs_first_pass.reload.check")
    mock_redraw = mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    # First tab starts the cycle → checks run
    tabs_first_pass.first_pass(*_make_args(index=1))
    # Second tab belongs to the same cycle → checks must not run again
    tabs_first_pass.first_pass(*_make_args(index=2))

    mock_reload.assert_called_once()
    mock_redraw.assert_called_once()


def test_all_tab_ids_reset_on_first_tab(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 5})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")
    tabState["allTabIds"] = [7, 8]

    tabs_first_pass.first_pass(*_make_args(index=1))

    assert tabState["allTabIds"] == [5]


def test_all_tab_ids_kept_on_later_tab(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 5})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")
    tabState["allTabIds"] = [7]

    tabs_first_pass.first_pass(*_make_args(index=2))

    assert tabState["allTabIds"] == [7, 5]


# --- Manifest population ---


def test_tab_data_stored_in_manifest_keyed_by_id(mocker):
    mocker.patch(
        "lib.tabs_first_pass.build_tab_data",
        return_value={"id": 42, "title": "foo"},
    )
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())

    assert 42 in tabState["manifest"]
    assert tabState["manifest"][42]["title"] == "foo"


def test_index_stored_on_tab_data_in_manifest(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args(index=7))

    assert tabState["manifest"][1]["index"] == 7


# --- allTabIds tracking ---


def test_tab_id_appended_to_all_tab_ids_on_first_call(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 5})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())

    assert 5 in tabState["allTabIds"]


def test_tab_id_not_duplicated_on_repeated_call(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 5})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())
    tabs_first_pass.first_pass(*_make_args())

    assert tabState["allTabIds"].count(5) == 1


# --- Active tab ---


def test_active_tab_id_set_when_active_tab_encountered(mocker):
    mocker.patch(
        "lib.tabs_first_pass.build_tab_data",
        return_value={"id": 3, "isActive": True},
    )
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args())

    assert tabState["activeTabId"] == 3


def test_active_tab_id_not_set_for_inactive_tab(mocker):
    mocker.patch(
        "lib.tabs_first_pass.build_tab_data",
        return_value={"id": 3, "isActive": False},
    )
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")
    tabState["activeTabId"] = 99

    tabs_first_pass.first_pass(*_make_args())

    assert tabState["activeTabId"] == 99


# --- Separator background ---


def test_separator_bg_set_to_next_tab_bg_when_next_tab_present(mocker):
    next_tab = MagicMock()
    mocker.patch(
        "lib.tabs_first_pass.build_tab_data",
        side_effect=[{"id": 1}, {"id": 2, "bg": 0xFF0000}],
    )
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args(next_tab=next_tab))

    assert tabState["manifest"][1]["separatorBg"] == 0xFF0000


def test_separator_bg_not_set_when_next_tab_is_none(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args(next_tab=None))

    assert "separatorBg" not in tabState["manifest"][1]


# --- End-of-cycle trigger ---


def test_pick_tabs_called_when_is_last_true(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mock_pick = mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    args = _make_args(is_last=True)
    tabs_first_pass.first_pass(*args)

    mock_pick.assert_called_once_with(args[1])


def test_pick_tabs_not_called_when_is_last_false(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mock_pick = mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")

    tabs_first_pass.first_pass(*_make_args(is_last=False))

    mock_pick.assert_not_called()


def test_end_of_cycle_steps_run_in_order_on_last_tab(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")

    call_order = []
    mocker.patch(
        "lib.tabs_first_pass.pick_tabs_to_display",
        side_effect=lambda screen: call_order.append("pick"),
    )
    mocker.patch(
        "lib.tabs_first_pass.tab_switch.check",
        side_effect=lambda: call_order.append("tab_switch"),
    )
    mocker.patch(
        "lib.tabs_first_pass.redraw.cleanup",
        side_effect=lambda: call_order.append("cleanup"),
    )

    tabs_first_pass.first_pass(*_make_args(is_last=True))

    assert call_order == ["pick", "tab_switch", "cleanup"]


def test_end_of_cycle_steps_skipped_mid_cycle(mocker):
    mocker.patch("lib.tabs_first_pass.build_tab_data", return_value={"id": 1})
    mocker.patch("lib.tabs_first_pass.reload.check")
    mocker.patch("lib.tabs_first_pass.redraw.check")
    mocker.patch("lib.tabs_first_pass.pick_tabs_to_display")
    mock_switch = mocker.patch("lib.tabs_first_pass.tab_switch.check")
    mock_cleanup = mocker.patch("lib.tabs_first_pass.redraw.cleanup")

    tabs_first_pass.first_pass(*_make_args(is_last=False))

    mock_switch.assert_not_called()
    mock_cleanup.assert_not_called()
