# pyright: reportMissingImports=false
# from datetime import datetime
# from kitty.boss import get_boss

import json
from pprint import pprint
from kitty.fast_data_types import (
    Screen,
    Color,
    # add_timer,
    get_options,
)
from kitty.utils import color_as_int
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    # Formatter,
    TabBarData,
    as_rgb,
    # draw_attributed_string,
    draw_title,
)


PROJECT_LIST = None

opts = get_options()
icon_fg = as_rgb(color_as_int(opts.color16))
icon_bg = as_rgb(color_as_int(opts.color8))
bat_text_color = as_rgb(color_as_int(opts.color15))
clock_color = as_rgb(color_as_int(opts.color15))
date_color = as_rgb(color_as_int(opts.color8))
SEPARATOR_SYMBOL, SOFT_SEPARATOR_SYMBOL = ("", "")
# RIGHT_MARGIN = 1
# REFRESH_TIME = 1
ICON = " !! "


# right_status_length = -1


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )

    return screen.cursor.x
    # global timer_id
    # global right_status_length
    # if timer_id is None:
    #     timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    # clock = datetime.now().strftime(" %H:%M")
    # date = datetime.now().strftime(" %d.%m.%Y")
    # cells = get_battery_cells()
    # cells.append((clock_color, clock))
    # cells.append((date_color, date))
    # right_status_length = RIGHT_MARGIN
    # for cell in cells:
    #     right_status_length += len(str(cell[1]))

    # _draw_icon(screen, index)
    # _draw_right_status(
    #     screen,
    #     is_last,
    #     cells,
    # )


def _oroshi_get_project_list():
    jsonPath = "/home/tim/.oroshi/config/zsh/theming/env/projects.json"
    projectList = {}

    rawProjectData = json.load(open(jsonPath, "r"))

    # First, build a top level hash of each project
    for key, value in rawProjectData.items():
        # Keep only name keys (ending with _NAME, but not FOREGROUND_NAME nor
        # BACKGROUND_NAME)
        if not (key.endswith("_NAME") and not key.endswith("GROUND_NAME")):
            continue

        projectName = value
        projectPrefix = key.replace("_NAME", "")
        projectList[projectName] = {"__prefix": projectPrefix}

    # Fill each entry with icon and colors
    kittyOptions = get_options()
    for _, projectData in projectList.items():
        projectPrefix = projectData["__prefix"]

        # Icon
        projectData["icon"] = rawProjectData.get(f"{projectPrefix}_ICON")

        # Background
        projectBgRaw = rawProjectData.get(f"{projectPrefix}_BACKGROUND", None)
        if projectBgRaw:
            projectData["bg"] = as_rgb(
                color_as_int(getattr(kittyOptions, f"color{projectBgRaw}"))
            )

        # Foreground
        projectFgRaw = rawProjectData.get(f"{projectPrefix}_FOREGROUND", None)
        if projectFgRaw:
            projectData["fg"] = as_rgb(
                color_as_int(getattr(kittyOptions, f"color{projectFgRaw}"))
            )

    return projectList


def _oroshi_tab_data(tab: TabBarData, draw_data: DrawData):
    if not tab:
        return {}

    global PROJECT_LIST
    tabTitle = tab.title
    projectData = PROJECT_LIST.get(tabTitle, {})
    tabIcon = projectData.get("icon", "")

    tabData = {
        "title": tabTitle,
        "icon": tabIcon,
    }

    defaultInactiveFg = as_rgb(int(draw_data.inactive_fg))
    defaultInactiveBg = as_rgb(int(draw_data.inactive_bg))
    defaultActiveFg = as_rgb(int(draw_data.active_fg))
    defaultActiveBg = as_rgb(int(draw_data.active_bg))

    # Inactive tab, revert to default styles
    if not tab.is_active:
        tabData["fg"] = defaultInactiveFg
        tabData["bg"] = defaultInactiveBg
    # Active tab, use project colors if defined
    else:
        tabData["fg"] = projectData.get("fg", defaultActiveFg)
        tabData["bg"] = projectData.get("bg", defaultActiveBg)

    return tabData


def _draw_left_status(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Build project list once
    global PROJECT_LIST
    if not PROJECT_LIST:
        PROJECT_LIST = _oroshi_get_project_list()

    # Definitions
    tabData = _oroshi_tab_data(tab, draw_data)
    tabTitle = tabData["title"]
    tabIcon = tabData["icon"]
    tabFg = tabData["fg"]
    tabBg = tabData["bg"]

    # Tab name
    screen.cursor.fg = tabFg
    screen.cursor.bg = tabBg
    screen.draw(f" {tabIcon}{tabTitle} ")

    # Separator
    defaultBg = as_rgb(int(draw_data.default_bg))
    nextTabData = _oroshi_tab_data(extra_data.next_tab, draw_data)
    screen.cursor.bg = nextTabData.get("bg", defaultBg)
    screen.cursor.fg = tabBg
    screen.draw("")

    return screen.cursor.x


# UNPLUGGED_ICONS = {
#     10: "",
#     20: "",
#     30: "",
#     40: "",
#     50: "",
#     60: "",
#     70: "",
#     80: "",
#     90: "",
#     100: "",
# }
# PLUGGED_ICONS = {
#     1: "",
# }
# UNPLUGGED_COLORS = {
#     15: as_rgb(color_as_int(opts.color1)),
#     16: as_rgb(color_as_int(opts.color15)),
# }
# PLUGGED_COLORS = {
#     15: as_rgb(color_as_int(opts.color1)),
#     16: as_rgb(color_as_int(opts.color6)),
#     99: as_rgb(color_as_int(opts.color6)),
#     100: as_rgb(color_as_int(opts.color2)),
# }


# def _draw_icon(screen: Screen, index: int) -> int:
#     if index != 1:
#         return 0
#     fg, bg = screen.cursor.fg, screen.cursor.bg
#     screen.cursor.fg = icon_fg
#     screen.cursor.bg = icon_bg
#     screen.draw(ICON)
#     screen.cursor.fg, screen.cursor.bg = fg, bg
#     screen.cursor.x = len(ICON)
#     return screen.cursor.x


# def _draw_right_status(screen: Screen, is_last: bool, cells: list) -> int:
#     if not is_last:
#         return 0
#     draw_attributed_string(Formatter.reset, screen)
#     screen.cursor.x = screen.columns - right_status_length
#     screen.cursor.fg = 0
#     for color, status in cells:
#         screen.cursor.fg = color
#         screen.draw(status)
#     screen.cursor.bg = 0
#     return screen.cursor.x


# def _redraw_tab_bar(_):
#     tm = get_boss().active_tab_manager
#     if tm is not None:
#         tm.mark_tab_bar_dirty()


# def get_battery_cells() -> list:
#     try:
#         with open("/sys/class/power_supply/BAT0/status", "r") as f:
#             status = f.read()
#         with open("/sys/class/power_supply/BAT0/capacity", "r") as f:
#             percent = int(f.read())
#         if status == "Discharging\n":
#             # TODO: declare the lambda once and don't repeat the code
#             icon_color = UNPLUGGED_COLORS[
#                 min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#             ]
#             icon = UNPLUGGED_ICONS[
#                 min(UNPLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
#             ]
#         elif status == "Not charging\n":
#             icon_color = UNPLUGGED_COLORS[
#                 min(UNPLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#             ]
#             icon = PLUGGED_ICONS[
#                 min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
#             ]
#         else:
#             icon_color = PLUGGED_COLORS[
#                 min(PLUGGED_COLORS.keys(), key=lambda x: abs(x - percent))
#             ]
#             icon = PLUGGED_ICONS[
#                 min(PLUGGED_ICONS.keys(), key=lambda x: abs(x - percent))
#             ]
#         percent_cell = (bat_text_color, str(percent) + "% ")
#         icon_cell = (icon_color, icon)
#         return [percent_cell, icon_cell]
#     except FileNotFoundError:
#         return []


# timer_id = None


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # global timer_id
    # global right_status_length
    # if timer_id is None:
    #     timer_id = add_timer(_redraw_tab_bar, REFRESH_TIME, True)
    # clock = datetime.now().strftime(" %H:%M")
    # date = datetime.now().strftime(" %d.%m.%Y")
    # cells = get_battery_cells()
    # cells.append((clock_color, clock))
    # cells.append((date_color, date))
    # right_status_length = RIGHT_MARGIN
    # for cell in cells:
    #     right_status_length += len(str(cell[1]))

    # _draw_icon(screen, index)
    _draw_left_status(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )
    # _draw_right_status(
    #     screen,
    #     is_last,
    #     cells,
    # )
    return screen.cursor.x
