import pytest
from unittest.mock import MagicMock, patch

import tab_bar


@pytest.fixture(autouse=True)
def reset_initialized():
    tab_bar._initialized = False
    yield


def _make_screen(cursor_x=42):
    screen = MagicMock()
    screen.cursor.x = cursor_x
    return screen


def _call_draw_tab(screen, for_layout=True):
    extra_data = MagicMock()
    extra_data.for_layout = for_layout
    return tab_bar.draw_tab(
        MagicMock(), screen, MagicMock(), 0, 10, 0, False, extra_data
    )


def test_init_tab_data_called_on_first_draw():
    with patch.object(tab_bar.tab_data, "init") as mock_init:
        _call_draw_tab(_make_screen())
        mock_init.assert_called_once()


def test_init_project_list_called_on_first_draw():
    with patch.object(tab_bar.projects, "init") as mock_init:
        _call_draw_tab(_make_screen())
        mock_init.assert_called_once()


def test_init_statusbar_called_on_first_draw():
    with patch.object(tab_bar.statusbar, "init") as mock_init:
        _call_draw_tab(_make_screen())
        mock_init.assert_called_once()


def test_init_not_called_again_on_subsequent_draws():
    with patch.object(tab_bar.projects, "init") as mock_init:
        _call_draw_tab(_make_screen())
        _call_draw_tab(_make_screen())
        mock_init.assert_called_once()


def test_returns_screen_cursor_x():
    assert _call_draw_tab(_make_screen(cursor_x=99)) == 99


def test_first_pass_called_when_for_layout():
    with patch.object(tab_bar.tabs_first_pass, "first_pass") as mock_pass:
        _call_draw_tab(_make_screen(), for_layout=True)
        mock_pass.assert_called_once()


def test_second_pass_called_when_not_for_layout():
    with patch.object(tab_bar.tabs_second_pass, "second_pass") as mock_pass:
        _call_draw_tab(_make_screen(), for_layout=False)
        mock_pass.assert_called_once()


def test_returns_cursor_x_modified_by_first_pass():
    screen = _make_screen(cursor_x=0)

    def set_cursor(*args):
        args[1].cursor.x = 77

    with patch.object(tab_bar.tabs_first_pass, "first_pass", side_effect=set_cursor):
        assert _call_draw_tab(screen, for_layout=True) == 77


def test_returns_cursor_x_modified_by_second_pass():
    screen = _make_screen(cursor_x=0)

    def set_cursor(*args):
        args[1].cursor.x = 55

    with patch.object(tab_bar.tabs_second_pass, "second_pass", side_effect=set_cursor):
        assert _call_draw_tab(screen, for_layout=False) == 55
