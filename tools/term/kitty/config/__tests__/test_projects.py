import pytest

import lib.projects as projects


@pytest.fixture(autouse=True)
def reset_state():
    projects.projectState.clear()
    yield


@pytest.fixture(autouse=True)
def mock_ansi(mocker):
    mocker.patch("lib.projects.ansi_to_kitty", side_effect=lambda n: n * 10)


def test_get_returns_empty_for_unknown_project():
    assert projects.get("unknown") == {}


def test_init_populates_all_fields(mocker):
    mocker.patch(
        "lib.projects.files.read_json",
        return_value={
            "oroshi": {
                "icon": "★",
                "background": {"ansi": 42},
                "backgroundInactive": {"ansi": 5},
                "foreground": {"ansi": 7},
            }
        },
    )
    projects.init()
    result = projects.get("oroshi")
    assert result["icon"] == "★"
    assert result["bg"] == 420
    assert result["bgInactive"] == 50
    assert result["fg"] == 70


def test_init_skips_missing_color_fields(mocker):
    mocker.patch("lib.projects.files.read_json", return_value={"oroshi": {"icon": "★"}})
    projects.init()
    result = projects.get("oroshi")
    assert "bg" not in result
    assert "bgInactive" not in result
    assert "fg" not in result
