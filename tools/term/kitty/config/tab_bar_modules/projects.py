import json
from tab_bar_modules.colors import getCursorColor

projectState = {"data": {}}


def getProjectData(projectName):
    return projectState["data"].get(projectName, {})


# Set the ALL_PROJECTS object, that contains name, icons and colors of all
# projects
def initProjectList():
    jsonPath = "/home/tim/.oroshi/tools/term/zsh/config/theming/dist/projects.json"
    with open(jsonPath) as f:
        rawProjectData = json.load(f)

    for projectName, project in rawProjectData.items():
        entry = {}

        if "icon" in project:
            entry["icon"] = project["icon"]

        bg = project.get("background", {}).get("ansi")
        if bg is not None:
            entry["bg"] = getCursorColor(bg)

        bgInactive = project.get("backgroundInactive", {}).get("ansi")
        if bgInactive is not None:
            entry["bgInactive"] = getCursorColor(bgInactive)

        fg = project.get("foreground", {}).get("ansi")
        if fg is not None:
            entry["fg"] = getCursorColor(fg)

        projectState["data"][projectName] = entry
