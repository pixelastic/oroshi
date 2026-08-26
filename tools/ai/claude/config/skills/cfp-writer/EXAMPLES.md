# CFP Examples

## Standalone

Good abstracts for inspiration. Use as reference for structure, tone, and specificity.

### Empathetic Questions Format

**Title:** Stop! Strategy Time! (...or are we really stopping?)

**Abstract:**
You may have heard your boss say it: "You need to be more strategic!". Maybe it
came up in your latest performance review. Or you just want to work more
strategically in order to fill all parts of your role as a leader.

But what does it actually mean to really think and act strategically? How can
you know that you are on the right path to becoming a more strategic leader?
What actions can you take to become more strategic every day? What skills can
you develop that help your ability to think and act strategically? How do you
find time to be more strategic in a fast-moving startup? How do you find time to
be more strategic in a large organization?

Many leaders want to (or even need to!) create space for more strategic work,
but it can be really hard to do so. In this talk, you will learn practical tips
that you can put to work immediately, and hear real examples from engineering
leaders who have worked through these challenges.

**Why this works:**
- Hook is immediately relatable ("You need to be more strategic!")
- Series of concrete questions frames the content clearly
- Shows empathy ("it can be really hard to do so")
- Promises actionable takeaways ("practical tips...immediately")
- Builds credibility ("real examples from engineering leaders")

---

### Concrete Problem → Actionable Solution

**Title:** Taming the Monolith: How We Migrated to Microservices Without Downtime

**Abstract:**
Our e-commerce platform handled 10M daily requests through a single Rails
monolith that had become impossible to scale. Every deploy was a white-knuckle
event. Teams couldn't move independently. Database migrations locked the entire
system for hours.

This talk chronicles our 18-month journey to microservices, focusing on the
practical patterns that made it possible: the Strangler Fig pattern for gradual
extraction, dual-write strategies for data consistency, and feature flags for
risk-free rollbacks.

You'll learn how we maintained 99.9% uptime throughout the migration, how we
identified service boundaries without getting paralyzed by analysis, and the
surprising lessons about team structure that made the technical work possible.
Whether you're planning a similar migration or just curious about the messy
reality behind the success stories, you'll leave with concrete strategies you
can apply tomorrow.

**Why this works:**
- Opens with concrete numbers (10M daily requests)
- Lists relatable pain points (white-knuckle deploys, locked migrations)
- Names specific technical patterns (Strangler Fig, dual-write, feature flags)
- Includes measurable outcomes (99.9% uptime, 18-month timeline)
- Acknowledges reality ("messy reality behind success stories")
- Clear promise of applicability ("apply tomorrow")

---

### Question → Debugging → Anti-patterns

**Title:** Why Is My React App So Slow? A Performance Debugging Deep Dive

**Abstract:**
Your React dashboard loads in 8 seconds. Your users are frustrated. Your
Lighthouse scores are abysmal. But where do you even start?

In this talk, we'll debug a real production performance problem from first
principles. You'll learn how to use Chrome DevTools to identify expensive
renders, how to interpret React Profiler flame graphs, and when to reach for
useMemo, useCallback, or code splitting.

We'll discover that the "obvious" solutions (memoization everywhere!) often make
things worse, while the real culprits hide in unexpected places: oversized
third-party libraries, unoptimized images, and state management anti-patterns.

By the end, you'll have a systematic approach to React performance debugging
that goes beyond cargo-cult optimization and helps you fix the issues that
actually matter.

**Why this works:**
- Title is a question everyone asks
- Hook starts with concrete pain (8 seconds, frustrated users)
- Promises hands-on approach ("debug a real production problem")
- Names specific tools (Chrome DevTools, React Profiler)
- Challenges assumptions ("obvious solutions often make things worse")
- Offers methodology over one-off tricks ("systematic approach")

## Before / After

Transformation pairs — added over time via the self-improvement phase.
