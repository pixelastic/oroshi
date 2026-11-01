# Google Calendar

The commands that let a shell or an agent read and manage Google Calendar. It
follows the [API glossary](/docs/api/GLOSSARY.md), and defines only the words of
this service. Its words are the words of the Google Calendar API.

This glossary defines only what is custom to Google Calendar. The base verbs
(`list`, `list-raw`, `search`, `read`, `create`, `update` and `delete`) are
defined in the API glossary and are not defined again here. Do not add an entry
for a base verb, even for a new command. The behavior of a command belongs in
the header of its wrapper.

## Language

### Authentication

**Account**:

The Google account whose OAuth tokens a command uses. This is an **OAuth API**,
and its **Login** is `google-login`, shared with Gmail and Google Docs.
`--account` selects the account, and the default account is used otherwise.

_Avoid_: profile, user

### Entities

**Calendar**:

A collection of **Events** that belongs to an **Account**. It has no **Anchor**,
and has a **Fixed schema**. `--calendarId` takes its id.

_Avoid_: agenda, schedule

`list-raw` prints the **Calendars** of the **Account**, as `▮` lines:
`calendarId▮name▮primary▮timeZone`. `primary` is `true` for the **Primary**. The
**Primary** comes first, then the others by name.

**Primary**:

The **Calendar** that has the id of the **Account**, and the default value of
`--calendarId`.

_Avoid_: default calendar, main calendar, personal calendar

**Event**:

An entry of a **Calendar**, with a title, a start and an end. `eventId` is its
id. Its **Anchor** is `--calendarId`, and it has a **Fixed schema**. An
occurrence of a recurring **Event** is an **Event** like any other.

_Avoid_: meeting, appointment, invitation

`list-raw` prints the **Events** of a period, as `▮` lines:
`eventId▮title▮status▮dateStart▮dateEnd▮isAllDay▮attendeeCount▮location▮isPrivate`.
The **Events** are sorted by start, the closest first. `status` is `confirmed`,
`tentative` or `cancelled`, and `attendeeCount` is the number of **Attendees**.
`isPrivate` is `true` only for a private **Event**. `read` prints `isAllDay` and
`isPrivate` too, but no `attendeeCount`: its `attendees` array has the count.

**All-day Event**:

An **Event** whose `dateStart` has no time. Its `dateEnd` is inclusive: an
**All-day Event** of one day has the same `dateStart` and `dateEnd`.

_Avoid_: full-day event, day event

`isAllDay` is `true` for an **All-day Event**. The commands print it for every
**Event**.

**Attendee**:

A person invited to an **Event**, identified by an e-mail address, and with a
`responseStatus`. It is not an **Entity** of its own: `read` lists the
**Attendees** of an **Event**, and `add` and `remove` change them. Its
**Anchor** is `--eventId`.

_Avoid_: guest, invitee, participant

**Private**:

An **Event** whose visibility is `private`: the readers of the **Calendar** see
that it is busy, but not its details. `--private` of `gcal-event-create` makes
one, and `--public` sends `default` instead. Both flags together fail with
`GCAL_VISIBILITY_CONFLICT`.

_Avoid_: hidden event, confidential event

`isPrivate` is `true` for a **Private** **Event**. The commands print it for
every **Event**. `confidential` is not handled: it gives `false`.

### Custom verbs

**`add`**:

A **Custom verb** of the `attendee` entity: `gcal-attendee-add` adds
**Attendees** to an **Event**.

**`remove`**:

A **Custom verb** of the `attendee` entity: `gcal-attendee-remove` removes one
**Attendee** of an **Event**.

## Relationships

- An **Account** has one or more **Calendars**
- An **Account** has exactly one **Primary**
- A **Calendar** holds zero or more **Events**
- An **Event** belongs to exactly one **Calendar**
- An **Event** has zero or more **Attendees**
- An **All-day Event** is an **Event**
- Every command uses the tokens of one **Account**
- No command sends an e-mail to an **Attendee**

## Flagged ambiguities

- "meeting" was used to mean an **Event**: resolved, the word is **Event**, as
  in the Google Calendar API.
- "personal" and "professional" calendars are uses, not types: an **Account**
  has one **Primary**, whatever its use. `--account` and `--calendarId` select
  the one to use.

## Example dialogue

> **Dev:** "To invite a person to an **Event**, do I update the **Event**?"
> **Domain expert:** "No. `gcal-attendee-add` adds an **Attendee** and keeps the
> others."
>
> **Dev:** "Is a day off an **Event**, or something else?" **Domain expert:**
> "It is an **All-day Event**. Its `dateEnd` is the last day, and `isAllDay` is
> `true`."
