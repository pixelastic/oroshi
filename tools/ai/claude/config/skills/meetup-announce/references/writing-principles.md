# Writing Principles

## Language

Always write in English, regardless of the meetup language.

When the talks are not in English, explicitly describe
what each talk will cover. The audience cannot read the
event page to get that information themselves.

## Hook with the topic, not logistics

The first sentence answers "why should I care," not
"when is it." Lead with what the event is about, not
the date or venue.

## Be concrete, not generic

Explain the topic in plain terms. "Getting your brand
cited by AI instead of ranked by Google" beats "search
in the age of AI." Avoid vague, high-level descriptions.

Name companies and people when you have the info.
"Crealo's experience" not "a company's experience."

## Every sentence has a verb

No noun-phrase-only sentences. "Three short talks covering
X" reads like AI output. "We'll have three talks" reads
like a person wrote it.

## No cliché catchphrases

No "X is dead, long live Y." No marketing slogans. Start
with a factual, direct statement.

## Vary sentence length

Mix short sentences (5–8 words) with medium (12–18) and
long (20+). Never write 5+ consecutive sentences within
3 words of each other in length. Monotone rhythm is the
strongest AI signal.

## First person, active voice, future tense

Write as Tim, the person hosting. "I could use a hand,"
not "help is appreciated." "We're hosting," not "a meetup
is being organized."

Use future tense for upcoming events: "We'll be hosting"
not "We're hosting." The event has not happened yet.

## Factual, no artificial urgency

Social proof is fine: "120+ people registered." Scarcity
is not: "almost no spots left." Internal audiences do not
need pressure. State facts, let people decide.

Always use the registration count (`guestRegisteredCount`),
not an estimated attendance. Say "registered," not "expected."

## Internal notes stay internal

Organizer backgrounds, series concepts, partnership
details from Airtable notes are context for writing,
not content for the message. Only include what helps
the reader decide to attend or help.

## No decorative emoji

No emoji in prose. Only use emoji as a functional
CTA (for example, "drop a :pizza: to help me count").

## Raw link at the end

Put the registration URL as a raw link on its own line,
at the end of the main message. No markdown links. Slack
does not reliably render pasted markdown.

## No redundancy

If the date is in the hook, do not repeat it in a
logistics block. Say each piece of information once.

## Reminders are self-contained

A reminder is a new message, not a thread reply. Start
with "Reminder:" then briefly recap the topic for people
who missed the original. Keep it short: topic, social
proof, CTA, link. Do not repeat the full initial message.

## Draft metadata

After the message body, add a `---` section with:
- Schedule time in human-readable format (for example,
  "Monday, September 8 at 2:06 PM")
- Attach instructions listing which assets to drag-drop

Initial messages posted immediately do not need a schedule
line.

## Past examples

Previously posted drafts live in
`$OROSHI_TMP_FOLDER/claude/meetup-announce/<recordId>/`.
Look there for inspiration, but follow these principles
over any older draft.
