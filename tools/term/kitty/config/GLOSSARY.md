# Kitty Tab Bar

The Kitty Tab Bar is the visual layer that displays tabs and system indicators.
It has three independent subsystems — Statusbar timers, Redraw, and Reload —
each with a distinct trigger and cost.

## Language

**Tab Bar**:
The top bar in Kitty, containing tabs on the left and the Statusbar on the right.
_Avoid_: tab line, top bar, header

**Statusbar**:
The right portion of the Tab Bar that displays auto-refreshing system indicators (CPU, RAM, etc.) on their own independent timers.
_Avoid_: status line, right bar, system bar

**Redraw**:
An operation that reads state files from disk (e.g., Notification Tab List) to pick up current runtime state, then forces the Tab Bar to re-render on the next frame. Does not re-read definition files or Python sources.
_Avoid_: refresh, update, repaint

**Reload**:
An operation that re-reads all definition files (icons, colors, projects JSON dist files) and re-imports Python source modules, then triggers a Redraw. Only needed when definitions change (new project, color change, code edit).
_Avoid_: refresh, redraw, reset

**State File**:
A file reflecting current runtime state, written by external tools during normal machine usage (e.g., Notification Tab List). Read on every Redraw.
_Avoid_: config file, data file

**Definition File**:
A file defining the Tab Bar's appearance or behaviour (icons/colors/projects JSON dist files, Python sources). Read only on Reload; changes rarely.
_Avoid_: config file, state file

**Redraw Beacon**:
A file whose presence on disk signals that a Redraw is needed; written by `kitty-redraw`, detected by the Tab Bar Python at the next render cycle, then immediately deleted. Lives at `$OROSHI_TMP_FOLDER/kitty/beacons/redraw`.
_Avoid_: beacon, refresh file, trigger file, flag file

**Reload Beacon**:
A file whose presence on disk signals that a Reload is needed; written by `kitty-reload`, detected by the Tab Bar Python at the next render cycle, then immediately deleted. Lives at `$OROSHI_TMP_FOLDER/kitty/beacons/reload`.
_Avoid_: beacon, refresh file, trigger file, flag file

**Tab ID**:
The integer identifier assigned by Kitty to a tab, unique among all currently open tabs.
_Avoid_: tab index, window ID, tab number

**Notify**:
The action of alerting the user that something happened in a tab. A Notify plays an optional sound (respects sound-mode) and adds a Notification Marker to the tab. Triggered by hooks (e.g., Claude Code's `stop` and `notification` hooks) when the tab is not focused.
_Avoid_: alert, ping

**Marker**:
A small UTF-8 symbol appended as a suffix to a tab's title in the Tab Bar, conveying information about the tab at a glance. Three kinds exist: Notification Marker, Fullscreen Marker, and Status Marker. A tab can display multiple markers simultaneously (e.g., fullscreen + notification).
_Avoid_: badge, indicator, tag, icon

**Notification Marker**:
A Marker signalling that something happened in a tab while the user was away. Added by a Notify. Auto-cleared after a short delay once the user focuses the tab.
_Avoid_: attention marker, attention icon, notification icon, alert icon

**Fullscreen Marker**:
A Marker shown when a tab is in fullscreen mode (Kitty's `stack` layout). Appears and disappears automatically based on layout state.
_Avoid_: fullscreen icon, fullscreen badge, stack indicator

**Status Marker**:
*(Planned)* A Marker indicating the current status of a tab (e.g., paused, grill-me session, running). A tab can only have one Status Marker at a time — setting a new one replaces the previous. Can be set manually or programmatically.
_Avoid_: activity marker, mode marker, skill marker

**Notification Tab List**:
A plain-text State File listing the Tab IDs that currently carry a Notification Marker, one `tabId` per line; read by the Tab Bar Python once per render cycle (at the start of each Redraw). Lives at `$OROSHI_TMP_FOLDER/kitty/attention`.
_Avoid_: attention file, attention list, notification file

## Relationships

- The **Tab Bar** contains one **Statusbar** and zero-or-more tabs
- The **Statusbar** updates independently of **Redraw** and **Reload** via its own timers
- A **Reload** always triggers exactly one **Redraw**
- A **Redraw** may or may not be preceded by a **Reload**
- `kitty-redraw` writes exactly one **Redraw Beacon** to trigger a **Redraw**
- `kitty-reload` writes exactly one **Reload Beacon** before triggering a **Redraw**
- The Tab Bar Python reads the **Redraw Beacon** and **Reload Beacon** at most once per render cycle, then deletes them
- A **Notify** adds a **Notification Marker** to a tab and optionally plays a sound
- A **Notify** only fires when the target tab is not focused
- The **Notification Tab List** is a **State File** — read once per render cycle (at the start of each **Redraw**); its content determines which tabs display a **Notification Marker**
- A **Notification Marker** is shown on a tab if and only if its **Tab ID** is present in the **Notification Tab List**
- A **Notification Marker** is auto-cleared after a short delay once the user focuses the tab
- A **Marker** is one of three kinds: **Notification Marker**, **Fullscreen Marker**, or **Status Marker**
- A tab can have at most one **Status Marker** at a time; setting a new one replaces the previous

## Flagged ambiguities

- "refresh" was used informally to mean both **Redraw** (visual only) and **Reload** (data + visual) — resolved: these are distinct operations with distinct scripts (`kitty-redraw` vs `kitty-reload`).
- The existing script `kitty-refresh` conflated both concepts — it is renamed `kitty-reload` as part of this project.
- "beacon" alone was considered — rejected in favour of **Redraw Beacon** / **Reload Beacon** to make the association with each operation explicit.
- "attention" was the original vocabulary for the notification system (Attention, Attention Icon, Attention File). Resolved: the entire family is renamed to the "notification" family (Notify, Notification Marker, Notification Tab List). Code still uses the old names (`attentionIds`, `kitty-tab-attention-add`, etc.) — a future sidequest handles the code rename.
- Claude Code has its own hook named `notification` — this is Claude Code's internal naming. Our **Notify** is the action that any hook (including Claude Code's `stop` and `notification` hooks) can trigger.

## Example dialogue

> **Dev:** "When should I call `kitty-reload` vs `kitty-redraw`?"
> **Domain expert:** "Use **Reload** when a definition file changed (new project, color tweak, Python code edit). Use **Redraw** when only runtime state changed (e.g., the **Notification Tab List** was updated) — it reads state files and re-renders without touching definitions."

> **Dev:** "Does the **Statusbar** update when I call `kitty-redraw`?"
> **Domain expert:** "No — the **Statusbar** runs on its own timers, completely independent of **Redraw** and **Reload**."

> **Dev:** "What happens when Claude finishes answering in a background tab?"
> **Domain expert:** "The `stop` hook fires a **Notify** — it plays a sound (if sound-mode allows) and adds a **Notification Marker** to the tab. When you switch to that tab, the **Notification Marker** auto-clears after a short delay."
