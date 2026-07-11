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
An operation that reads state files from disk (e.g., Attention File) to pick up current runtime state, then forces the Tab Bar to re-render on the next frame. Does not re-read definition files or Python sources.
_Avoid_: refresh, update, repaint

**Reload**:
An operation that re-reads all definition files (icons, colors, projects JSON dist files) and re-imports Python source modules, then triggers a Redraw. Only needed when definitions change (new project, color change, code edit).
_Avoid_: refresh, redraw, reset

**State File**:
A file reflecting current runtime state, written by external tools during normal machine usage (e.g., Attention File). Read on every Redraw.
_Avoid_: config file, data file

**Definition File**:
A file defining the Tab Bar's appearance or behaviour (icons/colors/projects JSON dist files, Python sources). Read only on Reload; changes rarely.
_Avoid_: config file, state file

**Reload Beacon**:
A file whose presence on disk signals that a Reload is needed; written by `kitty-reload`, detected by the Tab Bar Python at the next Redraw, then immediately deleted.
_Avoid_: beacon, refresh file, trigger file, flag file

**Tab ID**:
The integer identifier assigned by Kitty to a tab, unique among all currently open tabs.
_Avoid_: tab index, window ID, tab number

**Attention**:
The state of a tab that is awaiting a response from the user (Claude finished responding while the tab was inactive).
_Avoid_: notification, alert, pending, dirty

**Attention Icon**:
The icon `󱅫` displayed as a suffix on a tab's title in the Tab Bar to signal that the tab has Attention.
_Avoid_: attention badge, notification icon, alert icon

**Attention File**:
A plain-text file listing the Tab IDs currently in Attention state, one per line; read by the Tab Bar Python once per render cycle (at the start of each Redraw).
_Avoid_: attention list, notification file, state file

## Relationships

- The **Tab Bar** contains one **Statusbar** and zero-or-more tabs
- The **Statusbar** updates independently of **Redraw** and **Reload** via its own timers
- A **Reload** always triggers exactly one **Redraw**
- A **Redraw** may or may not be preceded by a **Reload**
- A **Reload** writes exactly one **Reload Beacon** before triggering a **Redraw**
- The Tab Bar Python reads the **Reload Beacon** at most once per **Redraw**, then deletes it
- The **Attention File** is a **State File** — read once per render cycle (at the start of each **Redraw**); its content determines which tabs display an **Attention Icon**
- An **Attention Icon** is shown on a tab if and only if its **Tab ID** is present in the **Attention File**

## Flagged ambiguities

- "refresh" was used informally to mean both **Redraw** (visual only) and **Reload** (data + visual) — resolved: these are distinct operations with distinct scripts (`kitty-redraw` vs `kitty-reload`).
- The existing script `kitty-refresh` conflated both concepts — it is renamed `kitty-reload` as part of this project.
- "beacon" alone was considered — rejected in favour of **Reload Beacon** to make the association with **Reload** explicit.

## Example dialogue

> **Dev:** "When should I call `kitty-reload` vs `kitty-redraw`?"
> **Domain expert:** "Use **Reload** when a definition file changed (new project, color tweak, Python code edit). Use **Redraw** when only runtime state changed (e.g., the **Attention File** was updated) — it reads state files and re-renders without touching definitions."

> **Dev:** "Does the **Statusbar** update when I call `kitty-redraw`?"
> **Domain expert:** "No — the **Statusbar** runs on its own timers, completely independent of **Redraw** and **Reload**."
