# Meetup Announce

Vocabulary for the meetup-announce skill, which generates audience-tailored Slack announcements across multiple channels with a stateful, multi-invocation timeline.

## Language

**Window**:
A time-bounded phase of the announcement lifecycle, determined by proximity to
the event date. There are exactly two: **Early** and **Last**.
_Avoid_: phase, round, pass

**Early**:
The **Window** spanning from the first invocation to D-2 (inclusive). Generates
all **Initials** and, when time permits, advance **Reminders**. Reminders are
skipped if their schedule date is already past.
_Avoid_: first, advance

**Last**:
The **Window** spanning D-1 and D-0. Generates **Reminders** that need fresh
data (registration counts). Never generated during the **Early** window.
_Avoid_: eve, late, final

**Initial**:
The first **Message** posted to a channel. Carries the core announcement. A
channel's **Reminders** depend on its **Initial** having been posted.
_Avoid_: first post, main message, announcement

**Reminder**:
A follow-up **Message** to an **Initial** in the same channel. Skipped if its
**Initial** was never posted. Most **Reminders** are standalone and schedulable.
Some are **Thread replies** posted manually.
_Avoid_: follow-up, update, ping

**Thread reply**:
A **Message** posted as a reply to its channel's **Initial** with Slack's "Also
send to channel" option checked. Gives thread continuity while remaining visible
in the channel. Cannot be scheduled in Slack — must be posted manually.
_Avoid_: reply, bump

**Message**:
A single Slack post targeting one channel at one point in the timeline. Has a
deterministic **Message ID**. Exists in one of three **States**: pending,
drafted, posted.
_Avoid_: draft (the file on disk), announcement (too vague)

**Message ID**:
The unique identifier for a **Message**, following the pattern
`<window>--<channel>--<type>`. Example: `early--office-paris--initial`. Also
used as the **Draft** filename (with `.md` extension).
_Avoid_: slug, key

**Draft**:
The markdown file on disk containing a **Message**'s content. Lives at `<draft
directory>/<messageId>.md`. For `#office-paris` **Initial**, contains both main
message and thread separated by `---`.
_Avoid_: message file, post

**Draft directory**:
The persistent folder for one meetup's announcement lifecycle, keyed by Airtable
record ID. Located at `/tmp/oroshi/claude/meetup-announce/<recordId>/`. Contains
`state.json`, **Draft** files, and an `assets/` subfolder. Reused across
invocations.
_Avoid_: session folder, workspace

**State**:
The lifecycle stage of a **Message**. One of: **pending** (not yet written),
**drafted** (**Draft** exists on disk), **posted** (user has posted it to
Slack).
_Avoid_: status

**Nudging**:
The adjustment of a schedule date to the nearest Tuesday, Wednesday, or
Thursday. Applied to **Early** **Reminders** only. Monday → Tuesday, Friday →
Thursday, Saturday/Sunday → next Tuesday.
_Avoid_: shifting, adjusting

**Topic-relevant channel**:
The channel discovered at runtime by asking Claude bot in Slack for channels
matching the meetup's subject matter. Varies per meetup. Always the last
**Message** written in the **Early** window.
_Avoid_: dynamic channel, variable channel

**Initial prerequisite**:
The rule that no **Reminder** can be generated for a channel unless that
channel's **Initial** has been posted. When a **Reminder** is due but the
**Initial** is missing, the **Initial** is generated in its place.
_Avoid_: catch-up rule, fallback

## Channels

Four channels, each with a distinct audience and communication goal. Messages grow shorter and more urgent as the event approaches.

### #office-paris

The primary announcement channel, reaching the most people.
Goal: make office people aware of the meetup so they stick around and potentially help.

| Message | Window | Posting | Content |
|---|---|---|---|
| **Initial** | Early | Standalone, schedulable | Main announcement (what, when, where) + thread with details (speakers, programme, links). The **Draft** contains both parts separated by `---`. |
| **Reminder D-7** | Early | Standalone, schedulable (scheduled for D-7, **nudged**) | Shorter recap — "pour rappel, c'est dans une semaine" with key info only. |
| **Reminder D-1** | Last | Standalone, posted manually | "On héberge le meetup X demain, on attend N personnes." Fresh registration count. |
| **Reminder D-0** | Last | Standalone, posted manually | "C'est ce soir, ne laissez rien traîner." Minimal, action-oriented. |

### #team-developer-marketing

Internal visibility for the developer marketing team.
Goal: show the team what's being organized and share impact metrics on the day.

| Message | Window | Posting | Content |
|---|---|---|---|
| **Initial** | Early | Standalone, schedulable | "Voilà le meetup qu'on héberge" — topic, programme, what's planned. Similar scope to office-paris initial but framed as team visibility. |
| **Reminder D-0** | Last | **Thread reply** ("also send to channel"), posted manually | "C'est ce soir, N inscrits" — concrete turnout numbers so the team sees the impact. |

### #help-recruiting

Bridge to the recruiting team for employer branding.
Goal: get job postings to display on meetup screens via QR codes.

| Message | Window | Posting | Content |
|---|---|---|---|
| **Initial** | Early | Standalone, schedulable | "On fait un meetup sur [sujet] le [date] — si vous avez des annonces d'emploi à mettre en avant, partagez-les moi pour les afficher sur les écrans." |
| **Reminder D-1** | Last | **Thread reply** ("also send to channel"), posted manually | Tone adapts to responses: relance if no reply, confirmation if postings were shared. Last chance to provide materials. |

### topic-relevant

A channel discovered at runtime matching the meetup's subject matter (e.g. #frontend, #data-engineering). Varies per meetup.
Goal: reach people interested in the topic who might attend, learn, network, or find prospects.

| Message | Window | Posting | Content |
|---|---|---|---|
| **Initial** | Early | Standalone, schedulable | Self-contained announcement — what, when, where, why it's relevant to this audience. No explicit link to #office-paris; the message must stand on its own. Always the last **Message** written in the **Early** window. |

## Relationships

- A **Window** contains one or more **Messages**
- A **Message** has exactly one **Message ID**, one **State**, and targets one channel
- A **Message** is either an **Initial** or a **Reminder**
- A **Reminder** depends on its channel's **Initial** (see **Initial prerequisite**)
- A **Draft** is the file representation of a **Message** with **State** = drafted or posted
- A **Draft directory** contains all **Drafts** and the `state.json` for one meetup

## Flagged ambiguities

- "session" was considered for the draft directory but rejected — a session is an invocation of the skill (ephemeral), while the draft directory is persistent across invocations.
- "today" was considered as a third message type alongside initial and reminder, but collapsed into reminder — a D-0 message is structurally a reminder with distinct content.
- "announcement" is avoided as a synonym for message — the entire skill is about announcements, so using it for individual messages would be ambiguous.
- `#help-recruiting` reminder was originally in the Early window, but moved to Last because: (1) its tone depends on whether anyone responded to the Initial, making it impossible to pre-draft, and (2) it's a thread reply, which Slack cannot schedule.

## Example dialogue

> **Tim:** "Write me the announcements for the Shift meetup."
> **Skill:** "You're at D-21, we're in the **Early** window. I'll generate 5 **Messages**: 4 **Initials** and 1 **Reminder**. The **Reminder** is scheduled for D-7, **nudged** to Thursday."
> **Tim:** "I've posted the office-paris initial."
> **Skill:** "Marked `early--office-paris--initial` as **posted**. Moving to the next **Draft**."
> **Tim:** (D-1) "Let's do the last round."
> **Skill:** "We're in the **Last** window. Fetching fresh data — 120 registered. I'll generate 4 **Reminders**: office-paris D-1, office-paris D-0, team-devmarketing D-0, and help-recruiting D-1 (thread reply)."
