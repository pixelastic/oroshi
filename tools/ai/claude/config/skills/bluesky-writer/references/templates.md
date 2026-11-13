# Templates

Four shapes for announcing a blog article. Pick the one that fits the strongest
angle of the article. Do not always pick the same. Each template is followed by
an example.

The brackets are slots. Every slot is optional, except the link. Paragraphs are
separated by blank lines. The link comes last, with at most two hashtags.

Each example is a post the user approved. Match its tone and rhythm, not its
words.

## A. Mishap and hint

```text
[Emoji] [A real moment from the work, in first person.]

[A hint of the payoff, without explaining it.]

[Optional invitation to reply.]

[Link] [Hashtags]
```

Example:

```text
😅 I didn't think I'd struggle that much to mock a function that sources another file in zsh.

All I had to do in the end was set a trap for it 🪤

Maybe there's a better way, but let me know if you found one.

http://blog.pixelastic.com/2026/11/10/mocking-sourced-zsh-functions/ #zsh
```

Why it works:

- It opens on a real moment, in first person, with a relieved emoji.
- The second paragraph hints at the solution without explaining it. The pun on
  "trap" rewards the reader who clicks.
- Blank lines separate the reaction, the hint, the open question and the link.
- The link comes last, with one hashtag.

## B. Confession and fix

```text
[A rule you know, and the habit that breaks it, with an emoji.]

[Why the tool does better than you, and what you wrote down for it.]

[Link]
```

Example:

```text
I know I shouldn't refactor everything at once, but I can't resist fixing small things 🙈

Agents are more disciplined than me, so I wrote them the rules I never followed myself: reduce, rewrite, restructure.

http://blog.pixelastic.com/2026/10/27/how-i-taught-my-agent-to-refactor-its-own-code/
```

Why it works:

- The first paragraph admits a flaw that the reader shares, and ends on an
  emoji.
- The second paragraph makes the flaw the reason for the article. The three
  names tease the content.
- The link comes last. It has no hashtag, because the length was tight.

## C. News and aside

```text
[The news, in one line, with what gives it weight: a duration, a count, a
before and after. Emoji.]

[One concrete detail that shows the effort, the cost or the surprise, then a
short wink.]

[Link]
```

Example:

```text
After 12 years on Jekyll, I finally migrated my blog to Eleventy 🙃

320 posts moved in two days instead of the usual months. And yes, agents did 90% of the code and the design.

http://blog.pixelastic.com/2026/10/23/migrating-blog-from-jekyll-to-eleventy/
```

Why it works:

- The first line gives the news and its weight: 12 years, "finally".
- The figure makes the reader curious, and "the usual months" is a shared joke.
- "And yes" winks at the reader. "Of course" did the same job but triggered the
  sycophancy rule of the linter.
- The figures come from the article.

## D. Confession and humility

```text
[What you did, and how you felt doing it, with an emoji.]

[A humble disclaimer about your legitimacy on the topic.]

[Link]
```

Example:

```text
I asked an AI to redesign my blog with only "I don't know what I want, but I'll know when I see it." I felt like the worst client a designer could get 😬

I'm no designer, so take it as a beginner's point of view.

http://blog.pixelastic.com/2026/10/23/migrating-blog-from-jekyll-to-eleventy/
```

Why it works:

- The first paragraph quotes a real sentence and admits how it felt.
- The disclaimer sets the expectations of the reader and disarms the experts.
- Without the disclaimer, this template becomes B.
- The quote keeps its period inside the quotation marks, as the linter wants.
