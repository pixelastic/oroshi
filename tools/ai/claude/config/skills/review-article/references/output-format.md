# Feedback Output Format

The synthesized feedback must follow this structure exactly. Language matches the article's language.

## Structure

```markdown
# Feedback — "<Article Title>"

## TL;DR

Overall impression in 2-3 sentences. Honest tone, no filler.

---

## Strengths

**<Named strength>.** Why it works, with specific reference to the article.

**<Named strength>.** ...

---

## Improvements

### <Axis name>

- **<Actionable title>.** Anchor quote from article + synthesized feedback explaining
  what to change and why.

- **<Actionable title>.** ...

### <Axis name>

- ...
```

## Rules

- **Axes adapt to the article.** Common axes: Narration, Content, Clarity/Style, Diagrams, Structure, Code Examples. Pick what fits — don't force axes that don't apply.
- **Anchor quotes.** Each improvement must reference a specific passage from the article. Use the closest matching excerpt.
- **Group by axis, not by comment.** Multiple comments about the same theme merge into one improvement item.
- **Severity is implicit.** Order improvements within each axis from most impactful to least.
- **No score, no grade.** The feedback is qualitative.
- **Strengths are specific.** Name what works and why — no generic praise.
- **Comment translation.** If comments are in French but the article is in English, translate the feedback to the article's language. Preserve the original intent.
- **Resolved comments.** If a comment points out something that is already addressed later in the article, do not include it as an improvement. Mention it only if the resolution is partial.
