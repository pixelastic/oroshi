# Draft format

The Draft is one Markdown file at the `draft` path of the Article folder.

## Rules

- Start with a front matter holding `title`, `date` and `description`.
- One H1 title, equal to the front matter `title`.
- H2 sections. No deeper level unless a section needs it.
- Fenced code blocks, each with a language.
- Images with relative links into the `images` folder and an alt text.
- No diagrams.
- English only.

## Template

````markdown
---
title: <title>
date: <YYYY-MM-DD>
description: <one sentence>
---

# <title>

<opening>

## <section>

<text>

```<language>
<code>
```
````
