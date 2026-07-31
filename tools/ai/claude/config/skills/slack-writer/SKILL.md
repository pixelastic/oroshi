---
name: slack-writer
description: Use when user needs to write a Slack message — replying to a colleague, announcing an event, or sharing information.
---

# Slack Writer

## Overview

Transform a brain dump (often speech-to-text) into a clear, concise Slack message. Two modes: **reply** (answering a colleague) and **announce** (posting to a channel). Same principles, different emphasis.

## Principles (by priority)

1. **Respect their attention.** The reader's time > your thoroughness. Every word must earn its place. Delete filler words (just, really, very, actually, basically, honestly, simply), filler phrases (I think that, it should be noted that, as you probably know), and repetitions. Stop writing when the point is made.

2. **Natural warmth.** Don't add warmth — don't kill it. The message should sound like a real person wrote it, not a template. No corporate speak, no fake enthusiasm, no "Great question!". If humor or a light tone fits, let it through. Emoji: sober in replies (occasional smile/wink for tone), more present in announces.

3. **Important thing first.** State the answer, the key info, or the point in the first sentence. Never build up to a conclusion. If the answer is yes or no, say it first, then explain. In announces, the event/project name and what it is goes first — don't bury the lead.

4. **Scannable.** Structure for the scanner. Use bullets for 2+ points. Use `code` for commands/paths/technical terms. Bold sparingly — only a key term, not whole sentences. No wall of text. Let whitespace breathe.

5. **Complete in one message.** Anticipate the follow-up and answer it. Include the answer + the why + a link or example. Never split greeting and content into separate messages.

## Links

- URL to a domain root → text is the domain: `<https://algolia.com|algolia.com>`
- URL to a subpage → text is a descriptive word from context: `<https://algolia.com/doc/guides/search|the documentation>`
- Always link on text, never paste raw long URLs.

## Core Workflow

### Step 1 — Assess context

**Goal:** Determine if you have enough information to write the message.

**Exit criterion:** You have all critical info, OR you've asked your clarifying questions.

Read the user's input (brain dump, file, conversation context). Identify the mode:
- **Reply** — answering a colleague's question or sharing info in DM/thread
- **Announce** — posting an event, project, or news to a channel

If critical info is missing (who's the audience, what's the key message, a date for an event), ask 1-2 targeted questions. If the input is complete, move directly to Step 2.

Bias: ask rather than guess. A wrong draft wastes more time than a quick question.

### Step 2 — Write draft

**Goal:** Produce a single Slack-ready message in English (French only if explicitly requested).

**Exit criterion:** A message the user can copy-paste into Slack.

Apply the 5 principles. No fixed template — let the format emerge from the content. Sometimes it's 2 lines of prose, sometimes a line + bullets, sometimes a short paragraph. Vary the structure across messages.

Output the message in a code block for easy copy-paste. No commentary after — the user will iterate if needed.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user prompted in French so I'll write in French" | Default English. French only if explicitly requested. |

## Checklist

- [ ] Important info is in the first sentence
- [ ] No filler words or phrases
- [ ] No repeated information
- [ ] Links are on text, not raw URLs
- [ ] Format varies from previous messages (no template feel)
- [ ] Language is English unless French was explicitly requested
