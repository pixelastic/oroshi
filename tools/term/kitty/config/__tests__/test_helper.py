
import lib.helper as helper


def test_ansi_to_kitty_returns_as_rgb_result(mocker):
    mocker.patch("lib.helper.color_as_int", return_value=999)
    mocker.patch("lib.helper.as_rgb", return_value=0xABCDEF)
    assert helper.ansi_to_kitty(42) == 0xABCDEF


def test_ansi_to_kitty_passes_color_int_to_as_rgb(mocker):
    mocker.patch("lib.helper.color_as_int", return_value=999)
    mock_rgb = mocker.patch("lib.helper.as_rgb")
    helper.ansi_to_kitty(42)
    mock_rgb.assert_called_once_with(999)


def test_ansi_to_kitty_reads_correct_color_index(mocker):
    mock_int = mocker.patch("lib.helper.color_as_int")
    mocker.patch("lib.helper.as_rgb")
    helper.ansi_to_kitty(42)
    mock_int.assert_called_once_with(helper.kittyOptions.color42)
