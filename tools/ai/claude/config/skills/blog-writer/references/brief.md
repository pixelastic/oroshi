# Brief

The Brief is the summary of one article. The user validates it before any
drafting.

## One Brief per article

A Brief covers exactly one article. Each article has its own Brief and its own
Article folder. When the content does not fit one article, split it. Do not
stretch one Brief.

## Content

| Part              | What it holds                                                                                                                                                   |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Angle             | The one point of the article, in one or two sentences                                                                                                           |
| Reader            | The default Reader, or the override with one sentence                                                                                                           |
| Outline           | The sections in order, one line each, following the Structure. A chronological article is written as such, ordered as a timeline: event, reaction, what follows |
| Length            | The estimated prose words, at most 2000                                                                                                                         |
| Split decision    | `single article`, or the list of articles with a slug each                                                                                                      |
| Assumed knowledge | What the article assumes, to recap in a short paragraph. Never a redirect to another article                                                                    |

## Length

- No minimum. Never pad.
- Maximum 2000 prose words. Front matter and fenced code are excluded. Inline
  code is included.
- Estimate from the Interview and the Source material.
- Over 2000: write the split proposal first, and no Brief until the user
  chooses.

## Split proposal

1. List the standalone articles: working title, angle and estimated words.
2. Each article stands alone. Where one builds on another, its Brief lists a
   short recap under Assumed knowledge.
3. Wait for the user's decision. Then write one Brief per article.

## Format

```markdown
# Brief: <working title>

**Angle:** <one or two sentences>

**Reader:** <default, or the override>

**Outline:**
1. <section>: <one line>

**Length:** <number> words

**Split decision:** <single article | list of slugs>

**Assumed knowledge:** <what to recap, or none>
```
