import lib.colors as colors


def test_ansi_to_kitty_returns_as_rgb_result(mocker):
    mocker.patch("lib.colors.color_as_int", return_value=999)
    mocker.patch("lib.colors.as_rgb", return_value=0xABCDEF)
    assert colors.ansi_to_kitty(42) == 0xABCDEF


def test_ansi_to_kitty_passes_color_int_to_as_rgb(mocker):
    mocker.patch("lib.colors.color_as_int", return_value=999)
    mock_rgb = mocker.patch("lib.colors.as_rgb")
    colors.ansi_to_kitty(42)
    mock_rgb.assert_called_once_with(999)


def test_ansi_to_kitty_reads_correct_color_index(mocker):
    mock_int = mocker.patch("lib.colors.color_as_int")
    mocker.patch("lib.colors.as_rgb")
    colors.ansi_to_kitty(42)
    mock_int.assert_called_once_with(colors.kittyOptions.color42)
