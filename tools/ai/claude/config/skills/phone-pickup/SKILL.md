---
name: phone-pickup
description: Use when user says "phone pickup", "pick up the conversation from the phone", "récupère la discussion du téléphone", or wants to retrieve a mobile vocal session saved in Notion.
---

# Phone Pickup

## Overview

Retrieve a mobile vocal session from Notion and resume the conversation in Claude Code.
This skill is read-only: it never creates, updates, or deletes Notion pages.

---

## Core Workflow

### Step 1 — List entries

Call `phone-pickup-list` to fetch all entries from the Notion database.

Parse the JSON output to extract, for each entry:
- `title` — the entry name
- `date` — entry date (added or last edited)
- `tags` — any associated tags

### Step 2 — Match

Match the user's description against title, date, and tags to identify the best candidate.

**If the match is unambiguous:** proceed to Step 3.

**If the match is ambiguous:** present the shortlist (title + date) and ask the user to choose before continuing.

### Step 3 — Read

Call `phone-pickup-read {page_id}` with the identified page ID to fetch the page block content.

### Step 4 — Present

Parse and present the content to the user, then continue the conversation as if it had started here.

---

## Checklist

- [ ] `phone-pickup-list` called and JSON parsed
- [ ] Best candidate identified (or user asked to choose)
- [ ] `phone-pickup-read {page_id}` called with the correct ID
- [ ] Content presented — ready to continue
