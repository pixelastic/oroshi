# Prompting

Written on 2026-09-28, from the official Midjourney docs:

| Article | Updated at |
|---|---|
| [Prompt Basics](https://docs.midjourney.com/hc/en-us/articles/32023408776205-Prompt-Basics) | 2026-08-31 |
| [Art of Prompting](https://docs.midjourney.com/hc/en-us/articles/32835253061645-Art-of-Prompting) | 2026-06-11 |
| [Text Generation](https://docs.midjourney.com/hc/en-us/articles/32502277092109-Text-Generation) | 2026-07-27 |

## Rules

- **Short and specific.** Write a quick snapshot of the idea, not instructions. No long lists, no "show me", no "make it".
  - Bad: `Show me a picture of lots of blooming California poppies, make them bright, vibrant orange, and draw them in an illustrated style with colored pencils`
  - Good: `Colored pencil illustration of bright orange California poppies`
- **Precise words.** Prefer specific synonyms: "gigantic" or "enormous" over "big".
- **Explicit numbers.** "three cats", not "cats". Or collective nouns: "flock of birds", not "birds".
- **Describe what you want, not what you don't.** "a party with no cake" may still show a cake. Exclusions go to `--no` (see `parameters.md`).
- **Always English.** Translate the description, including idioms, into natural English.

## Areas to cover

Cover an area only when it matters to the description. Fewer details give more variety, less control.

- **Subject:** who or what (person, animal, character, location, object)
- **Medium:** photo, painting, illustration, sculpture, doodle, tapestry, watercolor, block print, pixel art, ukiyo-e, oil painting…
- **Environment:** indoors, outdoors, underwater, in the city, forest, cave, desert…
- **Lighting:** soft, ambient, overcast, neon, studio lights
- **Color:** vibrant, muted, pastel, monochromatic, black and white, sepia, duotone
- **Mood:** playful, calm, gloomy, energetic, determined
- **Composition:** portrait, headshot, closeup, bird's-eye view
- **Time period:** "1920s illustration", "1400s"

## Text in the image

- Put the text to render inside double quotes: `"Midjourney"`. Single quotes do not work.
- Keep that text in the language the user asked for. Do not translate it.
- Introduce it with "with the words", "text" or "written".
- Keep it short.
  - Bad: `a logo with the company name Boing`
  - Good: `a pastel watercolor landscape with "imagine" written in the clouds`
- If text matters, add `--raw` or lower `--s` (see `parameters.md`).
