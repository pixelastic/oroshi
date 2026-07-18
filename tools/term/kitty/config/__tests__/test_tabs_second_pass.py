import pytest
from unittest.mock import MagicMock
from lib.tabs_second_pass import draw_tab_item, second_pass
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["displayedTabIds"] = []
    tabState["attentionIds"] = {}
    tabState["activeTabId"] = None
    yield


class _TrackingCursor:
    """Cursor that records (name, value) attribute assignments in order."""

    def __init__(self):
        object.__setattr__(self, "_assignments", [])
        object.__setattr__(self, "x", 0)

    def __setattr__(self, name, value):
        self._assignments.append((name, value))
        object.__setattr__(self, name, value)


def _make_screen_tracking():
    screen = MagicMock()
    screen.cursor = _TrackingCursor()
    return screen


def _make_tab_data(is_active=False):
    return {
        "fg": 0x112233,
        "bg": 0x445566,
        "title": "my-tab",
        "separatorBg": 0x778899,
        "separatorFg": 0xAABBCC,
        "isActive": is_active,
        "id": 1,
    }


def _make_tab(tab_id=1):
    tab = MagicMock()
    tab.tab_id = tab_id
    return tab


def _call_second_pass(tab_id=1, is_last=False, screen=None):
    if screen is None:
        screen = MagicMock()
    tabState["manifest"].setdefault(tab_id, _make_tab_data())
    tab = _make_tab(tab_id)
    return second_pass(MagicMock(), screen, tab, 0, 10, 1, is_last, MagicMock()), screen


# --- draw_tab_item ---


def test_draw_tab_item_sets_fg():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    assert ("fg", tab_data["fg"]) in screen.cursor._assignments


def test_draw_tab_item_sets_bg():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    assert ("bg", tab_data["bg"]) in screen.cursor._assignments


def test_draw_tab_item_draws_title():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    screen.draw.assert_any_call(tab_data["title"])


def test_draw_tab_item_sets_separator_bg():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    assert ("bg", tab_data["separatorBg"]) in screen.cursor._assignments


def test_draw_tab_item_sets_separator_fg():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    assert ("fg", tab_data["separatorFg"]) in screen.cursor._assignments


def test_draw_tab_item_draws_separator_glyph():
    screen = _make_screen_tracking()
    tab_data = _make_tab_data()
    draw_tab_item(tab_data, screen)
    assert screen.draw.call_count == 2


# --- second_pass — display filter ---


def test_displayed_tab_calls_draw_tab_item(mocker):
    tab_id = 1
    tabState["displayedTabIds"] = [tab_id]
    mock_draw = mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")

    _call_second_pass(tab_id=tab_id)

    mock_draw.assert_called_once()


def test_non_displayed_tab_skips_draw_tab_item(mocker):
    tab_id = 1
    tabState["displayedTabIds"] = []
    mock_draw = mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")

    _call_second_pass(tab_id=tab_id)

    mock_draw.assert_not_called()


# --- second_pass — end-of-cycle teardown (is_last=True) ---


def test_draw_statusbar_called_with_screen_on_last_tab(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.redraw")
    mock_statusbar = mocker.patch("lib.tabs_second_pass.draw_statusbar")
    screen = MagicMock()

    _call_second_pass(is_last=True, screen=screen)

    mock_statusbar.assert_called_once_with(screen)


# --- second_pass — mid-cycle (is_last=False) ---


def test_draw_statusbar_not_called_mid_cycle(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mock_statusbar = mocker.patch("lib.tabs_second_pass.draw_statusbar")

    _call_second_pass(is_last=False)

    mock_statusbar.assert_not_called()


# --- second_pass — return value ---


def test_returns_screen_cursor_x(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    screen = MagicMock()
    screen.cursor.x = 42

    result, _ = _call_second_pass(screen=screen)

    assert result == 42


# --- second_pass — activeTabId ---


def test_active_tab_id_set_when_active_tab_encountered(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    tabState["manifest"] = {
        1: _make_tab_data(is_active=True),
    }

    _call_second_pass(tab_id=1, is_last=False)

    assert tabState["activeTabId"] == 1


def test_active_tab_id_not_set_for_inactive_tab(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    tabState["manifest"] = {
        1: _make_tab_data(is_active=False),
    }
    tabState["activeTabId"] = 99

    _call_second_pass(tab_id=1, is_last=False)

    assert tabState["activeTabId"] == 99


# --- second_pass — cleanup call ---


def test_cleanup_called_on_last_tab(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    mock_redraw = mocker.patch("lib.tabs_second_pass.redraw")

    _call_second_pass(is_last=True)

    mock_redraw.cleanup.assert_called_once_with()


def test_cleanup_not_called_mid_cycle(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    mock_redraw = mocker.patch("lib.tabs_second_pass.redraw")

    _call_second_pass(is_last=False)

    mock_redraw.cleanup.assert_not_called()


# --- second_pass — tab_switch.check call ---


def test_tab_switch_check_called_on_last_tab(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    mocker.patch("lib.tabs_second_pass.redraw")
    mock_tab_switch = mocker.patch("lib.tabs_second_pass.tab_switch")

    _call_second_pass(is_last=True)

    mock_tab_switch.check.assert_called_once_with()


def test_tab_switch_check_not_called_mid_cycle(mocker):
    mocker.patch("lib.tabs_second_pass.draw_tab_item")
    mocker.patch("lib.tabs_second_pass.draw_statusbar")
    mocker.patch("lib.tabs_second_pass.redraw")
    mock_tab_switch = mocker.patch("lib.tabs_second_pass.tab_switch")

    _call_second_pass(is_last=False)

    mock_tab_switch.check.assert_not_called()
