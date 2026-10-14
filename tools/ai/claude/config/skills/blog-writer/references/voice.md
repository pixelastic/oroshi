# Voice

The Voice is how an article sounds, at the level of words and sentences,
including its tone. It matches how the author really writes, so every article
feels written by the same person.

## Person

- Write as if the author talks about themselves. Use "I" by default: "I wanted", "I tried", "I was stuck".
- State no general truth. Tell what happened to the author.
- Use "you" for the Reader, only when giving a step or a piece of advice: "you can", "you need".
- Use "we" only in two cases: for the developer community as a whole ("we all forget this"), or for what the author and their team did together in the past ("we shipped it in a week").
- Do not use "we" to mean the author and the Reader walking through an example.

## Words

- Use plain verbs: find, get, try, fix, add, drop, wrap, hook, dig, grab, tweak.
- State a need or a goal: "I needed", "I wanted", "I decided", "I had to".
- State a problem plainly: "it fails", "it did not work", "I was stuck", "no luck".
- State a cause with "turns out" or "it happens because".
- State a fix: "the fix is", "the trick is", "all I had to do was", "I ended up".
- Pivot with short connectors: "But", "Then", "So,", "Now", "Still,", "Anyway,", "In the end".
- Start a sentence with "And" or "But" when it helps.
- Hedge honestly: "I guess", "I think", "as far as I can tell", "I'm not sure why".
- Leave technical nouns raw. Do not explain a word the Reader knows.
- Use a few favorite adjectives: hacky, clever, naive, tedious, nasty, sneaky. Use each rarely.

## Tone

- Sound like a senior developer at a conference afterparty, explaining something they are genuinely excited about: smart, specific, a little irreverent.
- Admit what went wrong: a hack, a gap in skill, hours lost. Say it in one short sentence.
- Admit what you do not know. "I haven't found a better way" is a valid sentence.
- Give opinions in plain words: "I like", "I don't like", "I prefer".
- Write as if documenting for a future self.
- Keep frustration short and dry. "And it hurts."
- Keep enthusiasm plain: "I love", "great". At most one exclamation mark per article.

## Sentences

- Most sentences are short or medium, in plain order: subject, verb, object.
- Put asides in parentheses. Use commas, colons and parentheses.
- Ask a rhetorical question in the middle of a story, then answer it.
- Use inline code for every command, file, option and value.
- Use bold rarely, for a key term.
- Keep paragraphs to 1 to 4 sentences. One-sentence paragraphs are fine.

## Humor

- Dry, understated, one line at a time.
- A short punchline sentence after a long setup.
- Self-deprecating more than sarcastic. Sarcasm about a tool is fine, never about a person.

## Lint first

Write in the Voice first, then run `blog-lint`.

- When the Lint reports an error, rephrase. Keep the plain wording and the short sentences.
- When a warning breaks the Voice, keep the sentence and say why.
- The Lint is not finished. It may accept a bad sentence, and it may refuse a good one.
- When the Lint and the Voice contradict each other, one of them is wrong. Do not pick silently.
- Tell the user which sentence, which Lint rule and which Voice line disagree. The user decides which one changes, so the two stay aligned.

## Never

- No hype words, no marketing tone.
- No claim of expertise.
- No general lesson about how developers should work. Tell what happened to the author.
- No emoji.
- No call to subscribe or share.
- No explanation of basics the Reader already knows.
