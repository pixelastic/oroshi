import os
import pytest
from unittest.mock import MagicMock
import lib.redraw as redraw
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["manifest"] = {}
    tabState["allTabIds"] = []
    tabState["attentionIds"] = {}
    tabState["activeTabId"] = None
    redraw._attention_timer = None
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


# --- schedule_attention_clear — timer lifecycle ---


def test_timer_started_on_each_render_cycle(mocker):
    mock_timer_class = mocker.patch("lib.redraw.Timer")

    redraw.schedule_attention_clear()

    mock_timer_class.assert_called_once()
    mock_timer_class.return_value.start.assert_called_once()


def test_previous_timer_cancelled_before_starting_new_one(mocker):
    old_timer = MagicMock()
    redraw._attention_timer = old_timer
    mock_timer_class = mocker.patch("lib.redraw.Timer")

    redraw.schedule_attention_clear()

    old_timer.cancel.assert_called_once()
    mock_timer_class.return_value.start.assert_called_once()


def test_only_one_timer_live_at_a_time(mocker):
    mock_timer_class = mocker.patch("lib.redraw.Timer")

    redraw.schedule_attention_clear()
    first_timer = mock_timer_class.return_value

    mock_timer_class.reset_mock()
    redraw._attention_timer = first_timer
    redraw.schedule_attention_clear()

    first_timer.cancel.assert_called_once()
    assert mock_timer_class.call_count == 1


# --- _on_attention_clear callback ---


def test_callback_calls_attention_remove_for_active_tab(mocker):
    mock_run = mocker.patch("lib.redraw.subprocess.run")
    tabState["activeTabId"] = 1
    tabState["attentionIds"] = {"1": "notification"}

    redraw._on_attention_clear()

    mock_run.assert_called_once_with(["kitty-tab-attention-remove", "1"])


def test_callback_uses_tab_active_at_callback_time(mocker):
    mock_run = mocker.patch("lib.redraw.subprocess.run")
    tabState["activeTabId"] = 2
    tabState["attentionIds"] = {"1": "notification", "2": "stop"}

    redraw._on_attention_clear()

    mock_run.assert_called_once_with(["kitty-tab-attention-remove", "2"])


def test_callback_does_nothing_when_active_tab_has_no_attention(mocker):
    mock_run = mocker.patch("lib.redraw.subprocess.run")
    tabState["activeTabId"] = 1
    tabState["attentionIds"] = {"2": "stop"}

    redraw._on_attention_clear()

    mock_run.assert_not_called()
