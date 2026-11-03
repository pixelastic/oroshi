---
name: calendar-writer
description: Use when creating, updating, or deleting a Google Calendar event.
---

# Calendar Writer

## Overview

Create, update and delete Google Calendar events with the `gcal-*` helpers. Keep
it simple: act immediately, pick plausible values, never ask questions.

## Core Workflow

### Step 1 — Write the event

**Goal:** Produce an event the user understands at a glance.

**Exit criterion:** Title, dates and description are chosen.

- Write the title, description and location in English, even when the user
  speaks French.
- Title: explicit about what the user does.
- Description: guide the user when they open the event. Recall the goal, list
  the links to open. No fixed format. Keep it short.
- Dates: `YYYY-MM-DDTHH:MM`, local time, no offset.
- Duration: one hour, unless the user says otherwise.
- Missing information: choose a plausible value. Never ask the user.
- Long description: write it to a file in the scratchpad and pass
  `--description-file`.

### Step 2 — Run the helper

**Goal:** Apply the change to the calendar.

**Exit criterion:** The helper ran and printed the event.

- Create: `gcal-event-create`. Update: `gcal-event-update`.
- For a create or an update, run the helper immediately. Do not ask the user to
  confirm.
- Delete: `gcal-event-delete`. Always ask the user to confirm first.
- Find an `eventId` with `gcal-event-search` or `gcal-event-list-raw`.
- Read the flags with `helper-documentation <name>`.

## Common Rationalizations

| Rationalization                       | Reality                                          |
| ------------------------------------- | ------------------------------------------------ |
| "The user speaks French, so I do too" | Every event is in English, whatever the input.   |
| "I should confirm before creating"    | Create and update run at once. Only delete asks. |
| "A detail is missing, I will ask"     | Choose a plausible value. The user will correct. |

## Checklist

- [ ] Title, description and location are in English
- [ ] No confirmation asked for create or update
- [ ] Confirmation asked before every delete
