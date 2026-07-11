import os
import pytest
import lib.redraw as redraw
from lib.tabs import tabState


@pytest.fixture(autouse=True)
def reset_state():
    tabState["attentionIds"] = set()
    yield


@pytest.fixture(autouse=True)
def patch_paths(mocker, tmp_path):
    beacon_dir = tmp_path / "beacons"
    beacon_dir.mkdir()
    mocker.patch.object(redraw, "REDRAW_BEACON", str(beacon_dir / "redraw"))
    mocker.patch.object(redraw, "ATTENTION_FILE", str(tmp_path / "attention"))
    yield


def test_check_beacon_present_attention_exists():
    with open(redraw.REDRAW_BEACON, "w"):
        pass
    with open(redraw.ATTENTION_FILE, "w") as f:
        f.write("1\n2\n3\n")

    redraw.check()

    assert tabState["attentionIds"] == {"1", "2", "3"}
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_beacon_present_attention_absent():
    with open(redraw.REDRAW_BEACON, "w"):
        pass

    redraw.check()

    assert tabState["attentionIds"] == set()
    assert not os.path.exists(redraw.REDRAW_BEACON)


def test_check_beacon_absent():
    tabState["attentionIds"] = {"existing"}

    redraw.check()

    assert tabState["attentionIds"] == {"existing"}
