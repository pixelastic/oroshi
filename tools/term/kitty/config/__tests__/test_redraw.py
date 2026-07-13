import os
import pytest
import lib.redraw as redraw
from lib.state import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["attentionIds"] = {}
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
