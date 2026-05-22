---
name: slack-writer
description: Use when user needs to write Slack announcement messages but struggles with tone, length, or call-to-action. Triggers include 'help me write a Slack message', sharing personal projects, announcing meetups/events, or posting article links.
---

# Slack Message Writer

## Overview

Interactive skill for writing concise, authentic Slack announcement messages with the right tone and clear call-to-action. **Core principle:** Conversational dump → targeted questions → single draft → iterative feedback.

## When to Use

Use this skill when user:
- Wants to share personal projects ("I did this" channels)
- Announce events/meetups on internal Slack
- Share blog posts or articles
- Struggles with tone (too modest vs too salesy)
- Can't write concise messages (writes walls of text)
- Doesn't know how to write effective CTAs

**Do NOT use for:**
- Regular conversational Slack messages
- Direct messages to individuals
- Questions or status updates (different structure)

## Workflow

**MANDATORY:** Follow this exact workflow. Do NOT skip steps even under time pressure.

### Step 1: Gather Context (Free Dump)

Ask user to explain in their own words:

```
Tell me about what you want to share - just brain dump everything:
- What is it?
- Why did you make it?
- Who might be interested?
- What's the link (if any)?
```

**Do NOT write message yet.** Even if urgent. Even if they say "NOW".

### Step 2: Ask Targeted Questions

**CRITICAL:** You MUST ask at least ONE question before generating. Even if you think you have all info.

Based on their dump, ask 1-4 clarifying questions:

- What's the project/announcement?
- Why did you create it / why does it matter?
- Who's the audience?
- What's the URL?
- Any specific deadline or timing?
- What are you most proud of about this?

**Red Flag:** If you're tempted to skip questions because "user emphasized urgency" - STOP. Questions take 30 seconds. Writing wrong message wastes 10 minutes.

**You cannot skip to Step 3 without asking questions first. This is non-negotiable.**

### Step 3: Generate Single Message

Write ONE message following this EXACT structure with blank lines:

```
[One-line hook describing what it is]

[1-2 sentences context: why you made it/why it matters]

[CTA with link]
```

**REQUIRED blank lines between sections.** Not one long paragraph.

**Message Requirements:**
- **Length:** 3-4 separate lines (not one long line wrapping)
- **Structure:** Hook, blank line, context, blank line, CTA
- **Tone:** Authentic, conversational, casual
- **No marketing speak:** Avoid "excited to announce", "game-changer", "revolutionary"
- **No false modesty:** Don't undersell with "just a small thing"
- **Economy of words:** Every word must earn its place
- **Clear CTA:** Make it obvious what action to take

## Writing Style

**Conversational Flow (CRITICAL):**
- ❌ Short, punchy sentences that sound written ("Migrated it to Hugo. New design. All updated.")
- ✅ Longer, flowing sentences that sound like spoken English transcribed
- ❌ Phrases that feel like marketing copy or formal writing
- ✅ Phrases that sound like someone naturally talking and you wrote it down

**Punctuation for Natural Flow:**
- ❌ Space-dash-space separators (e.g., "been doing it as a hobby - it's fun")
- ✅ Commas, semicolons, or parentheses for natural, conversational flow
- ✅ Integrate clauses smoothly like in speech

**Emoji Usage:**
- ❌ Emoji isolated on its own line or at the very start (feels too formal/staged)
- ✅ Either skip the emoji entirely, or integrate it naturally if it fits
- Default: Skip emoji unless it feels genuinely natural to the content

**Context Recognition:**
- ✅ When appropriate, acknowledge shared context with "As some of you may know..." or similar
- This works well when the topic is a known hobby or interest

**Information Grouping:**
- ❌ Mention same info twice (hook mentions "3 years backlog", then details re-mention backlog)
- ✅ Group related information together in one place
- ✅ This is a Slack message, not a blog post with intro/body structure

**Tone Principle:**
- Think: "If I was speaking this out loud and someone transcribed it, would it sound like this?"
- If no → rewrite to sound more natural and conversational

**Link Formatting Logic:**

IF URL is clean (< 60 chars, no `?` parameters, no hash):
```
Check it out: https://painting.pixelastic.com
```

IF URL is ugly (> 60 chars, has `?utm_source=`, has hash/UUID):
```
<https://medium.com/ugly-url-here|Read the article>
```

### Step 4: Iterative Feedback (MANDATORY)

**You MUST ask for feedback after generating the message.** Do NOT skip this step.

After showing message, ALWAYS ask:
```
How does this feel? Any adjustments?
```

**Common feedback:**
- "Too long" → Cut to 3 lines, remove adjectives
- "Too casual/formal" → Adjust tone
- "CTA unclear" → Make action more explicit
- "Change this part" → Edit specific section

**Iterate until user is satisfied.** Then STOP. Don't ask "did you post it?"

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skip questions due to "urgency" | Questions take 30s. Wrong message wastes 10min. |
| Claim to ask questions but don't | Actually type out the questions. Don't lie. |
| Generate 2-3 versions | ONE version. Iterate based on feedback. |
| Write message > 5 lines | Cut ruthlessly. 3-4 lines is the target. |
| Compress into one long line | Use blank lines between hook/context/CTA. |
| Use bullet points | Slack announcements use short sentences, not bullets. |
| Skip emoji | Always suggest emoji. User can remove if they want. |
| Skip feedback question | Always ask "How does this feel?" |
| Ask "want me to send it?" | Just display. User will copy/paste themselves. |
| Marketing language | "Excited to announce" → "I made X" |
| Show ugly URL | Use `<URL\|text>` format for links with parameters |

## Rationalization Red Flags

If you find yourself thinking:

- "User emphasized NOW - I'll skip questions" → STOP. Follow workflow.
- "Asking questions would delay them" → 30 seconds vs 10 minutes. Ask.
- "I have enough context already" → You don't. Ask anyway.
- "It's easier to iterate on draft" → Iterating without context wastes time.
- "I'll provide multiple versions" → ONE version. User will give feedback.
- "I asked questions [but didn't actually ask them]" → That's lying. Actually ask.
- "I'll compress everything into one line to save space" → NO. Use blank lines for structure.
- "Emoji is optional, I'll skip it" → NO. Always suggest emoji.
- "User will ask if they want changes" → NO. You ask for feedback.

**All of these mean:** Follow the workflow. No shortcuts. No lying about what you did.

## Example

**User dump:**
> J'ai migré mon blog de peinture de figurines vers Hugo. Nouveau design, code refait, 2 ans de retard rattrapé. Je veux le partager sur "I did this" sans avoir l'air de me vanter. https://painting.pixelastic.com

**You ask:**
> What specific aspect are you most proud of? The design, the migration itself, or catching up on documentation?

**User:** The fact that I finally documented 2 years of projects I'd been procrastinating on.

**You generate:**
```
🎨 Finally migrated my miniature painting blog to Hugo

New design, complete rewrite, and I caught up on 2 years of project documentation I'd been putting off.

Check it out: https://painting.pixelastic.com
```

**User:** "Feels a bit long"

**You adjust:**
```
🎨 Migrated my miniature painting blog to Hugo - new design and 2 years of docs finally written

https://painting.pixelastic.com
```

**User:** "Perfect!"

---

**Based on research from:**
- [How to Write Effective Slack Announcements](https://www.charthop.com/resources/how-to-write-effective-slack-announcements)
- [Designing and formatting messages in Slack](https://slack.com/blog/collaboration/designing-and-formatting-messages-in-slack)
- [Call-to-Action Best Practices](https://www.v9digital.com/insights/call-action-best-practices-social-media/)
