import os
import sys
import pytest
import lib.reload as reload


@pytest.fixture(autouse=True)
def patch_beacon(mocker, tmp_path):
    beacon_dir = tmp_path / "beacons"
    beacon_dir.mkdir()
    mocker.patch.object(reload, "RELOAD_BEACON", str(beacon_dir / "reload"))
    yield


# --- beacon present ---


def test_check_beacon_present_deletes_beacon(mocker):
    with open(reload.RELOAD_BEACON, "w"):
        pass
    mocker.patch("importlib.reload")
    mocker.patch.dict(
        sys.modules,
        {
            "lib.projects": mocker.MagicMock(),
            "lib.tab_data": mocker.MagicMock(),
        },
    )
    reload.check()
    assert not os.path.exists(reload.RELOAD_BEACON)


def test_check_beacon_present_reloads_lib_modules(mocker):
    with open(reload.RELOAD_BEACON, "w"):
        pass
    mock_reload = mocker.patch("importlib.reload")
    fake_lib_extra = mocker.MagicMock()
    fake_other = mocker.MagicMock()
    mocker.patch.dict(
        sys.modules,
        {
            "lib.extra": fake_lib_extra,
            "other.module": fake_other,
            "lib.projects": mocker.MagicMock(),
            "lib.tab_data": mocker.MagicMock(),
        },
    )
    reload.check()
    reloaded = [call.args[0] for call in mock_reload.call_args_list]
    assert fake_lib_extra in reloaded
    assert fake_other not in reloaded


def test_check_beacon_present_calls_projects_init(mocker):
    with open(reload.RELOAD_BEACON, "w"):
        pass
    mocker.patch("importlib.reload")
    projects_mock = mocker.MagicMock()
    tab_data_mock = mocker.MagicMock()
    mocker.patch.dict(
        sys.modules,
        {
            "lib.projects": projects_mock,
            "lib.tab_data": tab_data_mock,
        },
    )
    reload.check()
    projects_mock.init.assert_called_once()


def test_check_beacon_present_calls_tab_data_init(mocker):
    with open(reload.RELOAD_BEACON, "w"):
        pass
    mocker.patch("importlib.reload")
    projects_mock = mocker.MagicMock()
    tab_data_mock = mocker.MagicMock()
    mocker.patch.dict(
        sys.modules,
        {
            "lib.projects": projects_mock,
            "lib.tab_data": tab_data_mock,
        },
    )
    reload.check()
    tab_data_mock.init.assert_called_once()


# --- beacon absent ---


def test_check_beacon_absent_no_reload(mocker):
    mock_reload = mocker.patch("importlib.reload")
    reload.check()
    mock_reload.assert_not_called()


def test_check_beacon_absent_no_init(mocker):
    projects_mock = mocker.MagicMock()
    mocker.patch.dict(sys.modules, {"lib.projects": projects_mock})
    reload.check()
    projects_mock.init.assert_not_called()
