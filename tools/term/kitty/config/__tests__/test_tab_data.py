import pytest

import lib.tab_data as tab_data


@pytest.fixture(autouse=True)
def reset_state():
    tab_data._icons = {}
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
