import os
import pytest
from lib import files
import lib.redraw as redraw
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["notificationIds"] = set()
    tabState["activeTabId"] = None
    yield


@pytest.fixture(autouse=True)
def patch_paths(mocker, tmp_path):
    beacon_dir = tmp_path / "beacons"
    beacon_dir.mkdir()
    mocker.patch.object(redraw, "REDRAW_BEACON", str(beacon_dir / "redraw"))
    mocker.patch.object(redraw, "NOTIFICATION_FILE", str(tmp_path / "attention"))
    yield


def test_check_parses_lines_into_set():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("42\n")

    redraw.check()

    assert tabState["notificationIds"] == {"42"}


def test_check_parses_multiple_lines():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n3\n")

    redraw.check()

    assert tabState["notificationIds"] == {"1", "2", "3"}
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_ignores_blank_lines():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n\n2\n\n")

    redraw.check()

    assert tabState["notificationIds"] == {"1", "2"}


def test_check_ignores_lines_with_colon():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n42:stop\n2\n")

    redraw.check()

    assert tabState["notificationIds"] == {"1", "2"}


def test_check_beacon_present_notification_absent():
    with open(redraw.REDRAW_BEACON, "w"):
        pass

    redraw.check()

    assert tabState["notificationIds"] == set()
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_beacon_absent():
    tabState["notificationIds"] = {"existing"}

    redraw.check()

    assert tabState["notificationIds"] == {"existing"}


# --- cleanup ---


def test_cleanup_removes_stale_entries():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n3\n")
    tabState["allTabIds"] = [1, 3]

    redraw.cleanup()

    with open(redraw.NOTIFICATION_FILE) as f:
        lines = [line.strip() for line in f if line.strip()]
    assert sorted(lines) == ["1", "3"]


def test_cleanup_preserves_live_entries():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n")
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()

    with open(redraw.NOTIFICATION_FILE) as f:
        lines = [line.strip() for line in f if line.strip()]
    assert sorted(lines) == ["1", "2"]


def test_cleanup_no_write_when_all_live():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n")
    mtime_before = os.path.getmtime(redraw.NOTIFICATION_FILE)
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()

    mtime_after = os.path.getmtime(redraw.NOTIFICATION_FILE)
    assert mtime_before == mtime_after


def test_cleanup_handles_empty_notification_file():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("")
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()


def test_cleanup_handles_missing_notification_file():
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()


def test_cleanup_empty_live_set_removes_all():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n")
    tabState["allTabIds"] = []

    redraw.cleanup()

    with open(redraw.NOTIFICATION_FILE) as f:
        content = f.read().strip()
    assert content == ""


def test_cleanup_resets_all_tab_ids():
    tabState["allTabIds"] = [1, 2, 3]

    redraw.cleanup()

    assert tabState["allTabIds"] == []


def test_cleanup_removes_stale_manifest_entries():
    tabState["allTabIds"] = [1]
    tabState["manifest"] = {1: {"title": "a"}, 99: {"title": "b"}}

    redraw.cleanup()

    assert 99 not in tabState["manifest"]


def test_cleanup_preserves_active_manifest_entries():
    tabState["allTabIds"] = [1, 2]
    tabState["manifest"] = {1: {"title": "a"}, 2: {"title": "b"}}

    redraw.cleanup()

    assert 1 in tabState["manifest"]
    assert 2 in tabState["manifest"]


# --- clear_notification ---


def test_clear_removes_tab_from_notification_file(mocker):
    mocker.patch("lib.redraw.get_boss")
    tabState["notificationIds"] = {"1"}
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n")

    redraw.clear_notification("1")

    assert files.read(redraw.NOTIFICATION_FILE) == ""
    assert "1" not in tabState["notificationIds"]


def test_clear_keeps_other_tabs_in_notification_file(mocker):
    mocker.patch("lib.redraw.get_boss")
    tabState["notificationIds"] = {"1", "2"}
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n")

    redraw.clear_notification("2")

    assert files.read(redraw.NOTIFICATION_FILE) == "1\n"
    assert "1" in tabState["notificationIds"]
    assert "2" not in tabState["notificationIds"]


def test_clear_does_nothing_when_tab_has_no_notification():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("2\n")

    redraw.clear_notification("1")

    assert files.read(redraw.NOTIFICATION_FILE) == "2\n"


def test_clear_does_nothing_when_notification_file_missing():
    redraw.clear_notification("1")

    assert not files.exists(redraw.NOTIFICATION_FILE)


def test_clear_marks_tab_bar_dirty(mocker):
    mock_boss = mocker.patch("lib.redraw.get_boss")
    tabState["notificationIds"] = {"1"}
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n")

    redraw.clear_notification("1")

    mock_boss().active_tab_manager.mark_tab_bar_dirty.assert_called_once()


def test_clear_clears_memory_when_file_has_no_entry(mocker):
    """Deadlock bug: if notificationIds has tab but file doesn't, clear must
    still pop from memory and repaint."""
    mock_boss = mocker.patch("lib.redraw.get_boss")
    tabState["notificationIds"] = {"1"}
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("2\n")

    redraw.clear_notification("1")

    assert "1" not in tabState["notificationIds"]
    mock_boss().active_tab_manager.mark_tab_bar_dirty.assert_called_once()


def test_clear_clears_memory_when_notification_file_missing(mocker):
    """Same deadlock but file doesn't exist at all."""
    mock_boss = mocker.patch("lib.redraw.get_boss")
    tabState["notificationIds"] = {"1"}

    redraw.clear_notification("1")

    assert "1" not in tabState["notificationIds"]
    mock_boss().active_tab_manager.mark_tab_bar_dirty.assert_called_once()


# --- cleanup memory ---


def test_cleanup_removes_stale_entries_from_memory():
    with open(redraw.NOTIFICATION_FILE, "w") as f:
        f.write("1\n2\n3\n")
    tabState["allTabIds"] = [1, 3]
    tabState["notificationIds"] = {"1", "2", "3"}

    redraw.cleanup()

    assert "2" not in tabState["notificationIds"]
    assert "1" in tabState["notificationIds"]
    assert "3" in tabState["notificationIds"]
