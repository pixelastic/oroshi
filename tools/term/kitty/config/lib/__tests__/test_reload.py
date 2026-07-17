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
    return {
        "lib.projects": _make_mock_module(has_init=True),
        "lib.tab_data": _make_mock_module(has_init=True),
    }


@pytest.fixture
def beacon(monkeypatch):
    mock_files = MagicMock()
    mock_files.exists.return_value = True
    mock_files.read.return_value = "/some/worktree\n"
    monkeypatch.setattr(reload, "files", mock_files)

    mock_util = MagicMock()
    mock_spec = MagicMock()
    mock_util.spec_from_file_location.return_value = mock_spec
    monkeypatch.setattr(reload.importlib, "util", mock_util)

    return mock_files, mock_util, mock_spec


@patch("lib.reload.files")
def test_does_nothing_when_beacon_missing(mock_files):
    mock_files.exists.return_value = False

    reload.check()

    mock_files.read.assert_not_called()
    mock_files.remove.assert_not_called()


def test_reads_beacon_content_as_source_path(beacon):
    mock_files, _, _ = beacon
    modules = {**_base_modules(), "lib.foo": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_files.read.assert_called_once_with(reload.RELOAD_BEACON)


def test_loads_module_from_beacon_path(beacon):
    _, mock_util, mock_spec = beacon
    mock_module = _make_mock_module()
    modules = {**_base_modules(), "lib.bar": mock_module}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_util.spec_from_file_location.assert_any_call(
        "lib.bar",
        "/some/worktree/tools/term/kitty/config/lib/bar.py",
    )
    mock_spec.loader.exec_module.assert_called()


def test_does_not_modify_sys_path(beacon):
    original_path = list(sys.path)
    modules = {**_base_modules(), "lib.baz": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    assert sys.path == original_path


def test_deletes_beacon_after_loading(beacon):
    mock_files, _, _ = beacon
    modules = {**_base_modules(), "lib.qux": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_files.remove.assert_called_once_with(reload.RELOAD_BEACON)


def test_reruns_init_functions(beacon):
    mock_projects = _make_mock_module(has_init=True)
    mock_tab_data = _make_mock_module(has_init=True)
    with patch.dict(
        sys.modules,
        {"lib.projects": mock_projects, "lib.tab_data": mock_tab_data},
    ):
        reload.check()

    mock_projects.init.assert_called_once()
    mock_tab_data.init.assert_called_once()


def test_strips_trailing_newline_from_beacon(beacon):
    mock_files, mock_util, _ = beacon
    mock_files.read.return_value = "/path/with/newline\n"
    modules = {**_base_modules(), "lib.x": _make_mock_module()}
    with patch.dict(sys.modules, modules):
        reload.check()

    mock_util.spec_from_file_location.assert_any_call(
        "lib.x",
        "/path/with/newline/tools/term/kitty/config/lib/x.py",
    )


def test_skips_non_lib_modules(beacon):
    _, mock_util, _ = beacon
    modules = {**_base_modules(), "os.path": MagicMock(), "json": MagicMock()}
    with patch.dict(sys.modules, modules):
        reload.check()

    called_names = [c.args[0] for c in mock_util.spec_from_file_location.call_args_list]
    assert "os.path" not in called_names
    assert "json" not in called_names
