import pytest
from unittest.mock import MagicMock

import lib.tab_data as tab_data
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tab_data._icons = {}
    tabState["attentionIds"] = {}
    yield


def test_init_loads_icons(mocker):
    mocker.patch(
        "lib.tab_data._read_json",
        return_value={"kitty-tab-attention": "!", "kitty-tab-fullscreen": "F"},
    )
    tab_data.init()
    assert tab_data._icons == {"kitty-tab-attention": "!", "kitty-tab-fullscreen": "F"}


def test_init_overwrites_on_second_call(mocker):
    mocker.patch("lib.tab_data._read_json", return_value={"kitty-tab-attention": "!"})
    tab_data.init()
    mocker.patch("lib.tab_data._read_json", return_value={"kitty-tab-fullscreen": "F"})
    tab_data.init()
    assert tab_data._icons == {"kitty-tab-fullscreen": "F"}


def test_no_io_at_import_time():
    # _icons is empty before init() is called — no file read at import time
    assert tab_data._icons == {}


# --- helpers ---


def _make_tab(tab_id=1, title="mytab", is_active=True, layout_name="tall"):
    tab = MagicMock()
    tab.tab_id = tab_id
    tab.title = title
    tab.is_active = is_active
    tab.layout_name = layout_name
    return tab


def _make_draw(
    default_bg=100, active_fg=200, active_bg=300, inactive_fg=400, inactive_bg=500
):
    draw = MagicMock()
    draw.default_bg = default_bg
    draw.active_fg = active_fg
    draw.active_bg = active_bg
    draw.inactive_fg = inactive_fg
    draw.inactive_bg = inactive_bg
    return draw


# --- build_tab_data: guard ---


def test_build_tab_data_returns_empty_when_tab_falsy():
    assert tab_data.build_tab_data(None, _make_draw()) == {}


# --- build_tab_data: basic fields ---


def test_build_tab_data_id(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(tab_id=42), _make_draw())
    assert result["id"] == 42


def test_build_tab_data_name(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(title="neovim"), _make_draw())
    assert result["name"] == "neovim"


def test_build_tab_data_is_active(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(is_active=False), _make_draw())
    assert result["isActive"] is False


def test_build_tab_data_is_fullscreen_when_stack(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    tab_data._icons = {"kitty-tab-fullscreen": "F"}
    result = tab_data.build_tab_data(_make_tab(layout_name="stack"), _make_draw())
    assert result["isFullscreen"] is True


def test_build_tab_data_not_fullscreen_otherwise(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(layout_name="tall"), _make_draw())
    assert result["isFullscreen"] is False


def test_build_tab_data_default_bg(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(), _make_draw(default_bg=999))
    assert result["defaultBg"] == 999


def test_build_tab_data_separator_bg_from_default_bg(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(), _make_draw(default_bg=999))
    assert result["separatorBg"] == 999


# --- build_tab_data: title construction ---


def test_title_with_project_icon(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={"icon": ">"})
    result = tab_data.build_tab_data(_make_tab(title="neovim"), _make_draw())
    assert result["title"] == " >neovim "


def test_title_without_project_icon(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(title="neovim"), _make_draw())
    assert result["title"] == " neovim "


def test_title_appends_attention_icon(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    tab_data._icons = {"kitty-tab-attention": "!"}
    tabState["attentionIds"] = {"1": "stop"}
    result = tab_data.build_tab_data(_make_tab(tab_id=1, title="neovim"), _make_draw())
    assert result["title"] == " neovim !"


def test_title_appends_fullscreen_icon_with_trailing_space(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    tab_data._icons = {"kitty-tab-fullscreen": "F"}
    result = tab_data.build_tab_data(
        _make_tab(title="neovim", layout_name="stack"), _make_draw()
    )
    assert result["title"] == " neovim F "


def test_title_appends_both_attention_and_fullscreen(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    tab_data._icons = {"kitty-tab-attention": "!", "kitty-tab-fullscreen": "F"}
    tabState["attentionIds"] = {"1": "stop"}
    result = tab_data.build_tab_data(
        _make_tab(tab_id=1, title="neovim", layout_name="stack"), _make_draw()
    )
    assert result["title"] == " neovim !F "


# --- build_tab_data: active tab colors ---


def test_active_fg_from_project(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={"fg": "red"})
    result = tab_data.build_tab_data(_make_tab(is_active=True), _make_draw())
    assert result["fg"] == "red"


def test_active_fg_fallback_to_draw_data(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(
        _make_tab(is_active=True), _make_draw(active_fg=200)
    )
    assert result["fg"] == 200


def test_active_bg_from_project(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={"bg": "blue"})
    result = tab_data.build_tab_data(_make_tab(is_active=True), _make_draw())
    assert result["bg"] == "blue"


def test_active_bg_fallback_to_draw_data(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(
        _make_tab(is_active=True), _make_draw(active_bg=300)
    )
    assert result["bg"] == 300


# --- build_tab_data: inactive tab colors ---


def test_inactive_bg_from_project(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={"bgInactive": "gray"})
    result = tab_data.build_tab_data(_make_tab(is_active=False), _make_draw())
    assert result["bg"] == "gray"


def test_inactive_bg_fallback_to_draw_data(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(
        _make_tab(is_active=False), _make_draw(inactive_bg=500)
    )
    assert result["bg"] == 500


def test_inactive_fg_from_project_bg(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={"bg": "blue"})
    result = tab_data.build_tab_data(_make_tab(is_active=False), _make_draw())
    assert result["fg"] == "blue"


def test_inactive_fg_fallback_to_draw_data(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(
        _make_tab(is_active=False), _make_draw(inactive_fg=400)
    )
    assert result["fg"] == 400


# --- build_tab_data: separator ---


def test_separator_fg_equals_bg(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(
        _make_tab(is_active=True), _make_draw(active_bg=300)
    )
    assert result["separatorFg"] == result["bg"]


def test_separator_bg_equals_default_bg(mocker):
    mocker.patch("lib.tab_data.as_rgb", side_effect=lambda x: x)
    mocker.patch("lib.tab_data.projects.get", return_value={})
    result = tab_data.build_tab_data(_make_tab(), _make_draw(default_bg=100))
    assert result["separatorBg"] == 100
