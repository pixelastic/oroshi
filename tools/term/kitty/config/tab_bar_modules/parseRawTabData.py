import json
import os
from kitty.tab_bar import DrawData, TabBarData, as_rgb
from tab_bar_modules.projects import get_project_data

# Load icons once at module level
_ICONS_PATH = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/icons.json"
with open(_ICONS_PATH) as _f:
    _icons = json.load(_f)

# Attention file — list of tab IDs that need user attention
_ATTENTION_FILE = "/home/tim/local/tmp/oroshi/kitty/attention"


# Parses raw data about the tab, as returned by kitty, into a flat object
def parseRawTabData(tab: TabBarData, draw_data: DrawData):
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
    projectData = get_project_data(name)
    icon = projectData.get("icon", "")

    # Read attention state fresh on every Redraw (not cached)
    isAttention = False
    if os.path.exists(_ATTENTION_FILE):
        with open(_ATTENTION_FILE) as f:
            attentionIds = {line.strip() for line in f if line.strip()}
        isAttention = str(id) in attentionIds

    # Build the title with icon, name, attention and potential full-screen icon
    title = f" {icon}{name} "
    if isAttention:
        title = f"{title}{_icons['kitty-tab-attention']}"
    if isFullscreen:
        title = f"{title}{_icons['kitty-tab-fullscreen']} "

    tabData = {
        "id": id,
        "name": name,
        "title": title,
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
