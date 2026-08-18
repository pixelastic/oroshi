from kitty.tab_bar import DrawData, TabBarData, as_rgb
from lib import files, projects
from lib.state import tabState

_ICONS_PATH = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/icons.json"
_COLORS_PATH = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/colors.json"
_icons = {}
_colors = {}


def init():
    global _icons, _colors
    _icons = files.read_json(_ICONS_PATH)
    _colors = files.read_json(_COLORS_PATH)


# Parses raw data about the tab, as returned by kitty, into a flat object
def build_tab_data(tab: TabBarData, draw_data: DrawData):
    # Quick fail if no tab
    if not tab:
        return {}

    # Default values
    defaultBg = as_rgb(int(draw_data.default_bg))

    # Find info from tab as passed by Kitty
    name = tab.title
    id = tab.tab_id
    isFullscreen = tab.layout_name == "stack"
    isActive = tab.is_active

    # Find info from the list of projects if one matches the same name
    projectData = projects.get(name)
    icon = projectData.get("icon", "")

    # Check notification state from tabState (populated once per render cycle)
    isNotification = str(id) in tabState["notificationIds"]

    # Build the title with icon, name, and fullscreen suffix
    title = f" {icon}{name} "
    if isFullscreen:
        title = f"{title}{_icons['kitty-tab-fullscreen']}"

    # Notification marker drawn separately with its own color
    notificationMarker = ""
    if isNotification:
        notificationMarker = _icons["kitty-tab-marker-notification"]

    tabData = {
        "id": id,
        "name": name,
        "title": title,
        "notificationMarker": notificationMarker,
        "isFullscreen": isFullscreen,
        "icon": icon,
        "isActive": isActive,
        "defaultBg": defaultBg,
        "separatorBg": defaultBg,
    }

    if isActive:
        # Active tab, use project colors if defined
        defaultActiveFg = as_rgb(int(draw_data.active_fg))
        defaultActiveBg = as_rgb(int(draw_data.active_bg))

        tabData["fg"] = projectData.get("fg", defaultActiveFg)
        tabData["bg"] = projectData.get("bg", defaultActiveBg)
    else:
        # Inactive tab, use inactive colors
        defaultInactiveFg = as_rgb(int(draw_data.inactive_fg))
        defaultInactiveBg = as_rgb(int(draw_data.inactive_bg))

        tabData["bg"] = projectData.get("bgInactive", defaultInactiveBg)
        tabData["fg"] = projectData.get("bg", defaultInactiveFg)

    # Separator color is the same as background color
    tabData["separatorFg"] = tabData["bg"]

    return tabData
