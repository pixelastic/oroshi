import pytest
import lib.tab_switch as tab_switch
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["activeTabId"] = None
    tab_switch._listeners = []
    tab_switch._last_tab_id = None
    yield


def test_fires_callback_on_tab_change(mocker):
    mock_add_timer = mocker.patch("lib.tab_switch.add_timer")
    callback = mocker.Mock()
    tab_switch.on_tab_switch(callback)
    tabState["activeTabId"] = 1

    tab_switch.check()

    mock_add_timer.assert_called_once()
    _, delay, repeat = mock_add_timer.call_args[0]
    assert delay == tab_switch.CALLBACK_DELAY
    assert repeat is False


def test_skips_callback_on_same_tab(mocker):
    mock_add_timer = mocker.patch("lib.tab_switch.add_timer")
    callback = mocker.Mock()
    tab_switch.on_tab_switch(callback)
    tabState["activeTabId"] = 1
    tab_switch._last_tab_id = "1"

    tab_switch.check()

    mock_add_timer.assert_not_called()


def test_timer_fires_callback_with_tab_id(mocker):
    mock_add_timer = mocker.patch("lib.tab_switch.add_timer")
    callback = mocker.Mock()
    tab_switch.on_tab_switch(callback)
    tabState["activeTabId"] = 42

    tab_switch.check()

    timer_fn = mock_add_timer.call_args[0][0]
    timer_fn()
    callback.assert_called_once_with("42")


def test_stale_callback_is_ignored(mocker):
    mock_add_timer = mocker.patch("lib.tab_switch.add_timer")
    callback = mocker.Mock()
    tab_switch.on_tab_switch(callback)

    # First tab switch
    tabState["activeTabId"] = 1
    tab_switch.check()
    stale_timer = mock_add_timer.call_args[0][0]

    # Second tab switch supersedes the first
    tabState["activeTabId"] = 2
    tab_switch.check()

    # Fire the stale callback — should no-op
    stale_timer()
    callback.assert_not_called()


def test_multiple_listeners_fire_independently(mocker):
    mock_add_timer = mocker.patch("lib.tab_switch.add_timer")
    cb1 = mocker.Mock()
    cb2 = mocker.Mock()
    tab_switch.on_tab_switch(cb1)
    tab_switch.on_tab_switch(cb2)
    tabState["activeTabId"] = 1

    tab_switch.check()

    assert mock_add_timer.call_count == 2
    # Fire both timers
    for call in mock_add_timer.call_args_list:
        call[0][0]()
    cb1.assert_called_once_with("1")
    cb2.assert_called_once_with("1")
