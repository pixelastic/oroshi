import json
from lib.helper import ansi_to_kitty

jsonPath = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/projects.json"
projectState = {}


def _read_json(path):
    with open(path) as f:
        return json.load(f)


# Read projects.json and build a flat dict of icon + Kitty-format colors
def init():
    rawProjectData = _read_json(jsonPath)

    for projectName, project in rawProjectData.items():
        entry = {}

        if "icon" in project:
            entry["icon"] = project["icon"]

        bg = project.get("background", {}).get("ansi")
        if bg is not None:
            entry["bg"] = ansi_to_kitty(bg)

        bgInactive = project.get("backgroundInactive", {}).get("ansi")
        if bgInactive is not None:
            entry["bgInactive"] = ansi_to_kitty(bgInactive)

        fg = project.get("foreground", {}).get("ansi")
        if fg is not None:
            entry["fg"] = ansi_to_kitty(fg)

        projectState[projectName] = entry


def get(projectName):
    return projectState.get(projectName, {})
