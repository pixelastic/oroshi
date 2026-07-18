import sys
from unittest.mock import MagicMock, patch

import pytest

from lib import reload


def _make_mock_module(has_init=False):
    mod = MagicMock()
    if not has_init:
        del mod.init
    return mod


def _base_modules():
    lib_pkg = MagicMock()
    lib_pkg.__path__ = ["/original/path"]
    return {
        "lib": lib_pkg,
        "lib.projects": _make_mock_module(has_init=True),
        "lib.tab_data": _make_mock_module(has_init=True),
    }


@pytest.fixture
def beacon(monkeypatch):
    mock_files = MagicMock()
    mock_files.exists.return_value = True
    mock_files.read.return_value = "/some/worktree\n"
    monkeypatch.setattr(reload, "files", mock_files)

    mock_reload = MagicMock()
    monkeypatch.setattr(reload.importlib, "reload", mock_reload)

    return mock_files, mock_reload


@patch("lib.reload.files")
def test_does_nothing_when_beacon_missing(mock_files):
    mock_files.exists.return_value = False

    reload.check()

    mock_files.read.assert_not_called()
    mock_files.remove.assert_not_called()


def test_reads_beacon_content_as_source_path(beacon):
    mock_files, _ = beacon
    modules = {**_base_modules(), "lib.foo": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_files.read.assert_called_once_with(reload.RELOAD_BEACON)


def test_reloads_lib_modules(beacon):
    _, mock_reload = beacon
    mock_module = _make_mock_module()
    modules = {**_base_modules(), "lib.bar": mock_module}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_reload.assert_any_call(mock_module)


def test_sets_lib_path_to_source(beacon):
    modules = _base_modules()
    lib_pkg = modules["lib"]
    with patch.dict(sys.modules, modules):
        reload.check()

    assert lib_pkg.__path__ == ["/some/worktree/tools/term/kitty/config/lib"]


def test_does_not_modify_sys_path(beacon):
    original_path = list(sys.path)
    modules = {**_base_modules(), "lib.baz": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    assert sys.path == original_path


def test_deletes_beacon_after_loading(beacon):
    mock_files, _ = beacon
    modules = {**_base_modules(), "lib.qux": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_files.remove.assert_called_once_with(reload.RELOAD_BEACON)


def test_reruns_init_functions(beacon):
    mock_projects = _make_mock_module(has_init=True)
    mock_tab_data = _make_mock_module(has_init=True)
    modules = {
        **_base_modules(),
        "lib.projects": mock_projects,
        "lib.tab_data": mock_tab_data,
    }
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_projects.init.assert_called_once()
    mock_tab_data.init.assert_called_once()


def test_strips_trailing_newline_from_beacon(beacon):
    mock_files, _ = beacon
    mock_files.read.return_value = "/path/with/newline\n"
    modules = _base_modules()
    lib_pkg = modules["lib"]
    with patch.dict(sys.modules, modules):
        reload.check()

    assert lib_pkg.__path__ == ["/path/with/newline/tools/term/kitty/config/lib"]


def test_skips_non_lib_modules(beacon):
    _, mock_reload = beacon
    os_path = MagicMock()
    json_mod = MagicMock()
    modules = {**_base_modules(), "os.path": os_path, "json": json_mod}
    with patch.dict(sys.modules, modules):
        reload.check()

    reloaded = [c.args[0] for c in mock_reload.call_args_list]
    assert os_path not in reloaded
    assert json_mod not in reloaded
