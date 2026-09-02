# Meetup Announce

Vocabulary for the meetup-announce skill, which generates audience-tailored Slack announcements across multiple channels with a stateful, multi-invocation timeline.

## Language

**Window**:
A time-bounded phase of the announcement lifecycle, determined by proximity to the event date. There are exactly two: **Early** and **Last**.
_Avoid_: phase, round, pass

**Early**:
The **Window** spanning from the first invocation to D-2 (inclusive). Generates all **Initials** and, when time permits, advance **Reminders**. Reminders are skipped if their schedule date is already past.
_Avoid_: first, advance

**Last**:
The **Window** spanning D-1 and D-0. Generates **Reminders** that need fresh data (registration counts). Never generated during the **Early** window.
_Avoid_: eve, late, final

**Initial**:
The first **Message** posted to a channel. Carries the core announcement. A channel's **Reminders** depend on its **Initial** having been posted.
_Avoid_: first post, main message, announcement

**Reminder**:
A follow-up **Message** to an **Initial** in the same channel. Skipped if its **Initial** was never posted.
_Avoid_: follow-up, update, ping

**Message**:
A single Slack post targeting one channel at one point in the timeline. Has a deterministic **Message ID**. Exists in one of three **States**: pending, drafted, posted.
_Avoid_: draft (the file on disk), announcement (too vague)

**Message ID**:
The unique identifier for a **Message**, following the pattern `<window>--<channel>--<type>`. Example: `early--office-paris--initial`. Also used as the **Draft** filename (with `.md` extension).
_Avoid_: slug, key

**Draft**:
The markdown file on disk containing a **Message**'s content. Lives at `<draft directory>/<messageId>.md`. For `#office-paris` **Initial**, contains both main message and thread separated by `---`.
_Avoid_: message file, post

**Draft directory**:
The persistent folder for one meetup's announcement lifecycle, keyed by Airtable record ID. Located at `/tmp/oroshi/claude/meetup-announce/<recordId>/`. Contains `state.json`, **Draft** files, and an `assets/` subfolder. Reused across invocations.
_Avoid_: session folder, workspace

**State**:
The lifecycle stage of a **Message**. One of: **pending** (not yet written), **drafted** (**Draft** exists on disk), **posted** (user has posted it to Slack).
_Avoid_: status

**Nudging**:
The adjustment of a schedule date to the nearest Tuesday, Wednesday, or Thursday. Applied to **Early** **Reminders** only. Monday → Tuesday, Friday → Thursday, Saturday/Sunday → next Tuesday.
_Avoid_: shifting, adjusting

**Topic-relevant channel**:
The channel discovered at runtime by asking Claude bot in Slack for channels matching the meetup's subject matter. Varies per meetup. Always the last **Message** written in the **Early** window.
_Avoid_: dynamic channel, variable channel

**Initial prerequisite**:
The rule that no **Reminder** can be generated for a channel unless that channel's **Initial** has been posted. When a **Reminder** is due but the **Initial** is missing, the **Initial** is generated in its place.
_Avoid_: catch-up rule, fallback

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

## Example dialogue

> **Tim:** "Write me the announcements for the Shift meetup."
> **Skill:** "You're at D-21, we're in the **Early** window. I'll generate 6 **Messages**: 4 **Initials** and 2 **Reminders**. The **Reminders** are scheduled for D-7, **nudged** to Thursday."
> **Tim:** "I've posted the office-paris initial."
> **Skill:** "Marked `early--office-paris--initial` as **posted**. Moving to the next **Draft**."
> **Tim:** (D-1) "Let's do the last round."
> **Skill:** "We're in the **Last** window. Fetching fresh data — 120 registered. I'll generate 3 **Reminders**: office-paris D-1, office-paris D-0, and team-devmarketing D-0."
