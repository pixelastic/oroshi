---
name: cfp-writer
description: Crafts compelling conference CFP submissions (title, abstract, takeaways). Use when user needs to write a Call for Paper, submit a talk proposal, or transform existing content into conference-ready format.
---

# CFP Writer

## Overview

Writing a strong Call for Papers (CFP) submission is the difference between speaking at a conference and being rejected. A compelling CFP requires more than summarizing your talk—it needs a hook that grabs attention, clear structure that demonstrates value, and concrete takeaways that prove attendees will learn something actionable.

This skill guides you through a structured process to transform talk materials (slides, outlines, ideas, or even existing CFP drafts) into conference-ready proposals. The result: a title (~10 words), abstract (~250 words), and 3-5 key takeaways that work for both selection committees and potential attendees.

**Why this matters:** Most CFP rejections happen because abstracts are too vague, lack clear structure, or fail to communicate value. A systematic approach eliminates these problems and dramatically improves acceptance rates.

## When to Use

Use this skill when:
- User needs to write a CFP for a conference talk
- User has talk content (slides, outline, notes) and needs to create a proposal
- User provides an existing CFP draft (theirs or a colleague's) that needs improvement
- User asks to "write a talk proposal", "submit to a conference", or "create an abstract"
- User mentions specific conferences like "I want to submit to [ConferenceName]"

**When NOT to use:**
- Writing blog posts or articles (different structure and goals)
- Writing academic paper abstracts (different conventions and format)
- User just wants to brainstorm talk ideas without submitting anywhere

## Core Process

Follow these five phases sequentially. Do not skip steps.

### Phase 1: Gather

**Goal:** Understand the talk content and CFP constraints.

1. **Ask what the user has:**
   - "What materials do you have? (slides, outline, idea, existing CFP draft, colleague's draft, etc.)"
   - If file path provided: Read it directly
   - If existing CFP provided: Note it as the starting point for improvement
   - Otherwise: Ask user to describe the talk content

2. **Ask for CFP constraints:**
   - Target conference or type of conference
   - Language (French or English)
   - Word limits if different from standard (~10 words title, ~250 words abstract)
   - Specific conference themes or required topics

3. **Extract talk essence:**
   - Main problem or question addressed
   - Key technical concepts, patterns, or tools covered
   - Target audience level (beginner, intermediate, advanced, mixed)
   - Unique angle or approach (what makes this talk different)
   - Real examples, case studies, or concrete outcomes if available

4. **If existing CFP provided:** Analyze it critically
   - Does it have a strong hook?
   - Is the structure clear (Hook → Context → Content → Takeaway)?
   - Are there concrete examples or is it vague?
   - Does it name specific technologies/patterns?
   - Are there buzzwords without explanation?
   - Is the value proposition obvious?

### Phase 2: Title Generation

**Goal:** Create a compelling, clear title (~10 words max).

**Generate 3-5 title options** using these proven patterns:

1. **Question Format**: "Why Is My [X] So [Problem]?" or "How Do You [Achieve Y]?"
2. **Problem-Solution**: "[Solving/Taming/Fixing] [Problem]: [Approach/Benefit]"
3. **Provocative/Contrarian**: "Stop [Common Practice]: [Better Alternative]"
4. **Learning-Focused**: "How to [Achieve Goal] with/without [Technology]"
5. **Direct Value**: "[Technology/Pattern]: [Specific Benefit or Deep Dive]"

**Title criteria (check each option):**
- ✅ Clear: No unexplained jargon
- ✅ Specific: Mentions concrete technologies/concepts when relevant
- ✅ Engaging: Value proposition or hook is obvious
- ✅ Honest: Doesn't overpromise
- ✅ Length: 5-10 words ideally, maximum 12

**Present options to user** with brief rationale:
```
Option 1: [Title]
→ [Why this works]

Option 2: [Title]
→ [Why this works]
...
```

**Iterate based on feedback** until user selects or refines a title.

### Phase 3: Abstract Writing

**Goal:** Write a ~250-word abstract with clear structure.

**Use this four-part structure:**

```
[HOOK - 1-2 sentences]
Why should attendees care? What problem or question does this address?
Start with something relatable or surprising.

[CONTEXT - 2-3 sentences]
What's the current situation? What challenges exist?
Paint the picture of why this matters now.

[CONTENT - 3-4 sentences]
What will the talk cover? What approach/solution/concepts?
Name specific patterns, tools, techniques—be concrete.

[TAKEAWAY - 1-2 sentences]
What will attendees learn? What can they do after?
Make the value explicit.
```

**Writing principles:**
- Use active voice and strong verbs
- Include 1-2 concrete examples, numbers, or use cases
- Name specific technologies, patterns, or frameworks (avoid "various tools")
- Avoid buzzwords without explanation ("leveraging synergies" ❌)
- Balance technical depth with accessibility
- Keep sentences short and scannable
- Show empathy for the audience's pain points
- Be honest about scope (don't overpromise)

**Generate draft abstract** → **Present to user** → **Iterate based on feedback**

### Phase 4: Key Takeaways

**Goal:** List 3-5 specific, actionable learning outcomes.

**Format:** "After this talk, you will be able to..."

**Takeaway requirements:**
- Start with an action verb (deploy, implement, identify, understand, build, debug, configure)
- Be specific (mention the actual technology/pattern/technique)
- Be scoped realistically for a 30-45min talk
- Be testable (could you verify someone learned this?)

**Examples:**

✅ **Good takeaways:**
- "Implement the Circuit Breaker pattern in your microservices using Resilience4j"
- "Identify the three most common React performance bottlenecks using Chrome DevTools"
- "Configure Kubernetes autoscaling based on custom metrics"

❌ **Bad takeaways (too vague):**
- "Understand microservices better"
- "Learn about React performance"
- "Know how Kubernetes works"

**Generate 3-5 takeaways** → **Review with user** → **Iterate**

### Phase 5: Final Review

**Run this verification checklist:**

- [ ] Title is under word limit and compelling
- [ ] Title uses one of the proven patterns
- [ ] Abstract follows structure (Hook → Context → Content → Takeaway)
- [ ] Abstract is within word count (~250 words, or specified limit)
- [ ] Abstract includes concrete examples or numbers
- [ ] Specific technologies/patterns are named (not just "tools" or "techniques")
- [ ] No unexplained jargon or buzzwords
- [ ] Takeaways are specific and actionable (start with verbs)
- [ ] 3-5 takeaways provided
- [ ] Language is grammatically correct
- [ ] Tone is professional but accessible (not academic, not overly casual)
- [ ] Content accurately represents the actual talk
- [ ] Value proposition is obvious to someone skimming quickly

**Present final CFP in clean, copy-pastable format:**

```markdown
# CFP Submission

## Title
[Title here]

## Abstract ([X] words)
[Abstract here]

## Key Takeaways
After this talk, you will be able to:
- [Takeaway 1]
- [Takeaway 2]
- [Takeaway 3]
- [Takeaway 4]
- [Takeaway 5]
```

## Reference Examples

These are real-world examples of excellent CFP submissions. Use them as inspiration for structure, tone, and specificity.

### Example 1: Empathetic Questions Format

**Title:** Stop! Strategy Time! (...or are we really stopping?)

**Abstract:**
You may have heard your boss say it: "You need to be more strategic!". Maybe it came up in your latest performance review. Or you just want to work more strategically in order to fill all parts of your role as a leader.

But what does it actually mean to really think and act strategically? How can you know that you are on the right path to becoming a more strategic leader? What actions can you take to become more strategic every day? What skills can you develop that help your ability to think and act strategically? How do you find time to be more strategic in a fast-moving startup? How do you find time to be more strategic in a large organization?

Many leaders want to (or even need to!) create space for more strategic work, but it can be really hard to do so. In this talk, you will learn practical tips that you can put to work immediately, and hear real examples from engineering leaders who have worked through these challenges.

**Why this works:**
- Hook is immediately relatable ("You need to be more strategic!")
- Series of concrete questions frames the content clearly
- Shows empathy ("it can be really hard to do so")
- Promises actionable takeaways ("practical tips...immediately")
- Builds credibility ("real examples from engineering leaders")

---

### Example 2: Concrete Problem → Actionable Solution

**Title:** Taming the Monolith: How We Migrated to Microservices Without Downtime

**Abstract:**
Our e-commerce platform handled 10M daily requests through a single Rails monolith that had become impossible to scale. Every deploy was a white-knuckle event. Teams couldn't move independently. Database migrations locked the entire system for hours.

This talk chronicles our 18-month journey to microservices, focusing on the practical patterns that made it possible: the Strangler Fig pattern for gradual extraction, dual-write strategies for data consistency, and feature flags for risk-free rollbacks.

You'll learn how we maintained 99.9% uptime throughout the migration, how we identified service boundaries without getting paralyzed by analysis, and the surprising lessons about team structure that made the technical work possible. Whether you're planning a similar migration or just curious about the messy reality behind the success stories, you'll leave with concrete strategies you can apply tomorrow.

**Why this works:**
- Opens with concrete numbers (10M daily requests)
- Lists relatable pain points (white-knuckle deploys, locked migrations)
- Names specific technical patterns (Strangler Fig, dual-write, feature flags)
- Includes measurable outcomes (99.9% uptime, 18-month timeline)
- Acknowledges reality ("messy reality behind success stories")
- Clear promise of applicability ("apply tomorrow")

---

### Example 3: Question → Debugging → Anti-patterns

**Title:** Why Is My React App So Slow? A Performance Debugging Deep Dive

**Abstract:**
Your React dashboard loads in 8 seconds. Your users are frustrated. Your Lighthouse scores are abysmal. But where do you even start?

In this talk, we'll debug a real production performance problem from first principles. You'll learn how to use Chrome DevTools to identify expensive renders, how to interpret React Profiler flame graphs, and when to reach for useMemo, useCallback, or code splitting.

We'll discover that the "obvious" solutions (memoization everywhere!) often make things worse, while the real culprits hide in unexpected places: oversized third-party libraries, unoptimized images, and state management anti-patterns.

By the end, you'll have a systematic approach to React performance debugging that goes beyond cargo-cult optimization and helps you fix the issues that actually matter.

**Why this works:**
- Title is a question everyone asks
- Hook starts with concrete pain (8 seconds, frustrated users)
- Promises hands-on approach ("debug a real production problem")
- Names specific tools (Chrome DevTools, React Profiler)
- Challenges assumptions ("obvious solutions often make things worse")
- Offers methodology over one-off tricks ("systematic approach")

## Common Rationalizations

Agents often try to skip steps or take shortcuts. Here's why those shortcuts fail:

| Rationalization | Reality |
|---|---|
| "I'll generate one perfect title instead of 3-5 options" | The first idea is rarely the best. Options let users compare and spark better ideas. Multiple options are required. |
| "The abstract is clear enough without specific technologies" | Vague abstracts like "we'll explore various techniques" tell committees nothing. Name the actual patterns, tools, and frameworks. |
| "I don't need to follow Hook → Context → Content → Takeaway" | This structure has been validated across thousands of successful CFPs. Skipping it produces unfocused abstracts that get rejected. |
| "Takeaways like 'understand X better' are fine" | Vague takeaways don't demonstrate value. "Understand X better" vs "Implement X using Y in Z context" - the second proves learning. |
| "250 words is just a guideline, 400 is okay" | Selection committees read hundreds of abstracts. Ignoring word limits signals you can't follow basic instructions. |
| "I'll skip the verification checklist to save time" | The checklist catches the mistakes that cause rejections. Every item exists because it's a common failure mode. |
| "The user's existing CFP is good enough" | If they're asking for help, it needs improvement. Always analyze critically and suggest concrete enhancements. |

## Red Flags

These patterns indicate a weak CFP that will likely be rejected:

**Title red flags:**
- Generic buzzwords without specifics ("Cloud-Native Transformation Journey")
- Vague action words ("Exploring", "Discovering", "Understanding")
- No clear value proposition or hook
- Over 12 words
- Academic/formal style for a tech conference ("A Comprehensive Analysis of...")

**Abstract red flags:**
- Opens with "Wikipedia defines [X] as..." or "This talk will cover..."
- No concrete examples, numbers, or named technologies
- Lots of buzzwords: "leverage", "synergies", "best practices", "deep dive" without substance
- Teases the solution instead of revealing it ("Come find out!")
- Passive voice throughout ("It will be shown that...")
- No clear structure (wall of text without logical flow)
- Overpromising ("Master Kubernetes in 45 minutes!")

**Takeaway red flags:**
- Vague verbs ("understand", "learn", "know") without specifics
- Too broad for a single talk ("Build scalable distributed systems")
- Passive phrasing ("Knowledge of X will be gained")
- Generic ("Best practices for Y")
- Fewer than 3 or more than 5 items

## Verification

Before considering the CFP complete, verify:

- [ ] All five phases were completed (Gather → Title → Abstract → Takeaways → Review)
- [ ] User provided or confirmed the talk content
- [ ] At least 3 title options were generated (unless user provided an already-excellent title)
- [ ] Final title is 5-12 words and uses a proven pattern
- [ ] Abstract follows Hook → Context → Content → Takeaway structure
- [ ] Abstract includes at least one specific technology, pattern, or concrete example
- [ ] Abstract is within word count (check against user's specified limit or ~250 default)
- [ ] 3-5 key takeaways are provided
- [ ] Each takeaway starts with an action verb and is specific
- [ ] Final verification checklist from Phase 5 was completed
- [ ] Output is formatted for easy copy-paste
- [ ] If existing CFP was provided, improvements are concrete and explained

**Quality self-check:** Could someone unfamiliar with the topic read this CFP and clearly explain:
1. What problem the talk addresses?
2. What specific techniques/tools/patterns will be covered?
3. What they'll be able to do after attending?

If the answer to any is "not really", the CFP needs revision.
