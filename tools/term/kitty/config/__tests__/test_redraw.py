import os
import pytest
from lib import files
import lib.redraw as redraw
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["attentionIds"] = {}
    tabState["activeTabId"] = None
    redraw._attention_callback_counter = 0
    redraw._attention_callback_tab_id = None
    yield


@pytest.fixture(autouse=True)
def patch_paths(mocker, tmp_path):
    beacon_dir = tmp_path / "beacons"
    beacon_dir.mkdir()
    mocker.patch.object(redraw, "REDRAW_BEACON", str(beacon_dir / "redraw"))
    mocker.patch.object(redraw, "ATTENTION_FILE", str(tmp_path / "attention"))
    yield


def test_check_parses_typed_lines_into_dict():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n2:notification\n3:stop\n")

    redraw.check()

    assert tabState["attentionIds"] == {"1": "stop", "2": "notification", "3": "stop"}
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_ignores_blank_lines():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n\n2:notification\n\n")

    redraw.check()

    assert tabState["attentionIds"] == {"1": "stop", "2": "notification"}


def test_check_beacon_present_attention_absent():
    with open(redraw.REDRAW_BEACON, "w"):
        pass

    redraw.check()

    assert tabState["attentionIds"] == {}
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_beacon_absent():
    tabState["attentionIds"] = {"existing": "stop"}

    redraw.check()

    assert tabState["attentionIds"] == {"existing": "stop"}


# --- cleanup ---


def test_cleanup_removes_stale_entries():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n2:notification\n3:stop\n")
    tabState["allTabIds"] = [1, 3]

    redraw.cleanup()

    with open(redraw.ATTENTION_FILE) as f:
        lines = [line.strip() for line in f if line.strip()]
    assert sorted(lines) == ["1:stop", "3:stop"]


def test_cleanup_preserves_live_entries():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n2:notification\n")
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()

    with open(redraw.ATTENTION_FILE) as f:
        lines = [line.strip() for line in f if line.strip()]
    assert sorted(lines) == ["1:stop", "2:notification"]


def test_cleanup_no_write_when_all_live():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n2:notification\n")
    mtime_before = os.path.getmtime(redraw.ATTENTION_FILE)
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()

    mtime_after = os.path.getmtime(redraw.ATTENTION_FILE)
    assert mtime_before == mtime_after


def test_cleanup_handles_empty_attention_file():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("")
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()


def test_cleanup_handles_missing_attention_file():
    tabState["allTabIds"] = [1, 2]

    redraw.cleanup()


def test_cleanup_empty_live_set_removes_all():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n2:notification\n")
    tabState["allTabIds"] = []

    redraw.cleanup()

    with open(redraw.ATTENTION_FILE) as f:
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


# --- schedule_attention_clear — add_timer + generation ---


def test_schedule_registers_timer_on_tab_change(mocker):
    mock_add_timer = mocker.patch("lib.redraw.add_timer")
    tabState["activeTabId"] = 1

    redraw.schedule_attention_clear()

    mock_add_timer.assert_called_once()
    _, delay, repeat = mock_add_timer.call_args[0]
    assert delay == redraw.ATTENTION_CLEAR_DELAY
    assert repeat is False
    assert redraw._attention_callback_counter == 1


def test_schedule_skips_timer_on_same_tab(mocker):
    mock_add_timer = mocker.patch("lib.redraw.add_timer")
    tabState["activeTabId"] = 1
    redraw._attention_callback_tab_id = "1"

    redraw.schedule_attention_clear()

    mock_add_timer.assert_not_called()


def test_schedule_callback_clears_attention_for_active_tab(mocker):
    mock_add_timer = mocker.patch("lib.redraw.add_timer")
    mocker.patch("lib.redraw.get_boss")
    tabState["activeTabId"] = 2
    tabState["attentionIds"] = {"2": "stop"}
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:notification\n2:stop\n")

    redraw.schedule_attention_clear()
    callback = mock_add_timer.call_args[0][0]
    callback()

    assert files.read(redraw.ATTENTION_FILE) == "1:notification\n"
    assert "2" not in tabState["attentionIds"]


def test_schedule_stale_callback_is_ignored(mocker):
    mock_add_timer = mocker.patch("lib.redraw.add_timer")
    tabState["activeTabId"] = 1
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n")

    # First schedule
    redraw.schedule_attention_clear()
    stale_callback = mock_add_timer.call_args[0][0]

    # Second schedule — supersedes the first
    tabState["activeTabId"] = 2
    redraw.schedule_attention_clear()

    # Fire the stale callback — should do nothing
    stale_callback()

    assert files.read(redraw.ATTENTION_FILE) == "1:stop\n"


def test_schedule_callback_skips_tab_without_attention(mocker):
    mock_add_timer = mocker.patch("lib.redraw.add_timer")
    tabState["activeTabId"] = 1
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("2:stop\n")

    redraw.schedule_attention_clear()
    callback = mock_add_timer.call_args[0][0]
    callback()

    assert files.read(redraw.ATTENTION_FILE) == "2:stop\n"


# --- _clear_attention ---


def test_clear_removes_tab_from_attention_file(mocker):
    mocker.patch("lib.redraw.get_boss")
    tabState["attentionIds"] = {"1": "notification"}
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:notification\n")

    redraw._clear_attention("1")

    assert files.read(redraw.ATTENTION_FILE) == ""
    assert "1" not in tabState["attentionIds"]


def test_clear_keeps_other_tabs_in_attention_file(mocker):
    mocker.patch("lib.redraw.get_boss")
    tabState["attentionIds"] = {"1": "notification", "2": "stop"}
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:notification\n2:stop\n")

    redraw._clear_attention("2")

    assert files.read(redraw.ATTENTION_FILE) == "1:notification\n"
    assert "1" in tabState["attentionIds"]
    assert "2" not in tabState["attentionIds"]


def test_clear_does_nothing_when_tab_has_no_attention():
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("2:stop\n")

    redraw._clear_attention("1")

    assert files.read(redraw.ATTENTION_FILE) == "2:stop\n"


def test_clear_does_nothing_when_attention_file_missing():
    redraw._clear_attention("1")

    assert not files.exists(redraw.ATTENTION_FILE)


def test_clear_marks_tab_bar_dirty(mocker):
    mock_boss = mocker.patch("lib.redraw.get_boss")
    tabState["attentionIds"] = {"1": "stop"}
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1:stop\n")

    redraw._clear_attention("1")

    mock_boss().active_tab_manager.mark_tab_bar_dirty.assert_called_once()
