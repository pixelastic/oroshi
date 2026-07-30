---
name: review-article
description: Use when user says "review article", "review this article", or `/review-article`. Uploads Markdown or Google Docs URL for annotation, waits for comments, synthesizes structured feedback, publishes as a shareable Google Doc.
argument-hint: <file.md or Google Docs URL>
---

# Review Article

## Overview

End-to-end article review: upload to Google Docs, wait for annotations, synthesize feedback, publish as a shareable doc.

---

## Core Workflow

### Step 1 — Prepare

**Goal:** Get the article into Google Docs for annotation.

**Exit criterion:** Google Docs URL presented to the user.

Extract the file path or URL from the skill argument. If no argument, ask the user.

Run `review-article-start <input>` and parse the JSON output. The `url` field contains the Google Docs URL.

Present the URL to the user:

> Here's the doc: {url}
>
> Go annotate it with your comments. Tell me when you're done.

Stop and wait for the user.

---

### Step 2 — Wait

**Goal:** User confirms they're done annotating.

**Exit criterion:** User said they're done (or equivalent).

Do nothing until the user comes back. Any indication that comments are ready counts: "done", "finished", "go", "comments are in", etc.

---

### Step 3 — Fetch

**Goal:** Retrieve the article content and comments from Google Docs.

**Exit criterion:** Markdown content and comments JSON in hand.

Run both commands, capturing their output:

1. `gdocs2md <url>` — outputs a directory path. Read `{outputDir}/index.md` for the article markdown.
2. `gdocs-comments-json <url>` — outputs a JSON array of `{ anchor, comment }` objects.

---

### Step 4 — Synthesize

**Goal:** Cross-reference comments against the full article and produce structured feedback.

**Exit criterion:** Feedback markdown written to a temp file.

1. Read the article markdown and the comments JSON.
2. Read the output format reference at `references/output-format.md`.
3. Auto-detect the article's language (default to English).
4. For each comment:
   - Match its `anchor` to the corresponding passage in the article.
   - If the issue raised by the comment is addressed later in the article, discard it (auto-resolve).
   - If the comment is in French but the article is in another language, translate the feedback.
5. Group remaining comments by thematic axis (Narration, Content, Clarity/Style, Diagrams, etc. — axes adapt to the article). Within each axis, order from most impactful to least.
6. Write the feedback following the output format reference: TL;DR, Strengths, Improvements grouped by axis.
7. Write the feedback markdown to `/tmp/oroshi/review-article/feedback.md`.

---

### Step 5 — Publish

**Goal:** Upload the feedback as a shareable Google Doc.

**Exit criterion:** Shareable URL returned to the user.

Run `md2gdocs --title "<Article Title> (review)" --no-open /tmp/oroshi/review-article/feedback.md`. The command outputs the Google Docs URL.

Present the URL to the user:

> Here's the review: {url}

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can synthesize feedback without fetching the full article" | You need the full article to auto-resolve comments and produce anchor quotes. Fetch it. |
| "I'll skip auto-resolving, the user can filter" | Auto-resolving is the whole point of synthesizing vs. forwarding raw comments. |
| "I'll publish the feedback as a message instead of a Google Doc" | The deliverable is a shareable Google Doc. Always publish via `md2gdocs`. |
| "Comments are in French, I'll keep them in French" | Feedback language matches the article's language. Translate. |

## Checklist

- [ ] Input resolved (file path or URL)
- [ ] `review-article-start` called and URL presented
- [ ] Waited for user confirmation
- [ ] `gdocs2md` called and article markdown read
- [ ] `gdocs-comments-json` called and JSON parsed
- [ ] Output format reference read
- [ ] Article language detected
- [ ] Comments cross-referenced against full article
- [ ] Addressed comments auto-resolved
- [ ] French comments translated to article language
- [ ] Feedback written following output format (TL;DR, Strengths, Improvements)
- [ ] Feedback published via `md2gdocs --title` and URL returned
