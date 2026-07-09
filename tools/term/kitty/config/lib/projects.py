import json
from lib.colors import get_cursor_color

projectState = {"data": {}}


def get_project_data(projectName):
    return projectState["data"].get(projectName, {})


# Set the ALL_PROJECTS object, that contains name, icons and colors of all
# projects
def init():
    jsonPath = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/projects.json"
    with open(jsonPath) as f:
        rawProjectData = json.load(f)

    for projectName, project in rawProjectData.items():
        entry = {}

        if "icon" in project:
            entry["icon"] = project["icon"]

        bg = project.get("background", {}).get("ansi")
        if bg is not None:
            entry["bg"] = get_cursor_color(bg)

        bgInactive = project.get("backgroundInactive", {}).get("ansi")
        if bgInactive is not None:
            entry["bgInactive"] = get_cursor_color(bgInactive)

        fg = project.get("foreground", {}).get("ansi")
        if fg is not None:
            entry["fg"] = get_cursor_color(fg)

        projectState["data"][projectName] = entry
