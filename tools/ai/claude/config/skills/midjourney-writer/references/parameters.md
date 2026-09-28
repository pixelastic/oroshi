# Parameters (V8.2)

Written on 2026-09-28, from the official Midjourney docs:

| Article | Updated at |
|---|---|
| [Parameter List](https://docs.midjourney.com/hc/en-us/articles/32859204029709-Parameter-List) | 2026-09-01 |
| [Aspect Ratio](https://docs.midjourney.com/hc/en-us/articles/31894244298125-Aspect-Ratio) | 2026-07-27 |
| [No](https://docs.midjourney.com/hc/en-us/articles/32173351982093-No) | 2026-07-27 |
| [Raw](https://docs.midjourney.com/hc/en-us/articles/32634113811853-Raw) | 2026-07-27 |
| [Stylize](https://docs.midjourney.com/hc/en-us/articles/32196176868109-Stylize) | 2026-07-27 |
| [Chaos / Variety](https://docs.midjourney.com/hc/en-us/articles/32099348346765-Chaos-Variety) | 2026-07-27 |
| [Weird](https://docs.midjourney.com/hc/en-us/articles/32390120435085-Weird) | 2026-07-27 |
| [Image Size & Resolution](https://docs.midjourney.com/hc/en-us/articles/33329374594957-Image-Size-Resolution) | 2026-07-27 |

`midjourney-writer-end` adds `--ar 16:9` when no ratio is set, forces `--v 8.2`, and removes forbidden parameters and `::` weights.

## Formatting

- Parameters go at the end of the prompt, in this order: `<text> [--no …] [agent's choice] [--ar <ratio>]`.
- Put a space before each `--`.
- No punctuation in parameters: no commas, no periods. Exception: `--no` lists items separated by commas.

## Aspect ratio

Omit `--ar` for the default ratio. Use another ratio only when the description clearly requires it: `--ar 9:16` for a vertical story or phone wallpaper, `--ar 2:3` for a portrait print, `--ar 1:1` for an avatar or a square post. No decimals: `139:100`, not `1.39:1`.

## Only on explicit request

- `--no <item>, <item>` — Only when the user explicitly excludes something ("without X", "no X"). Each word is read independently: `--no modern clothing` means "no modern" and "no clothing". Prefer describing what you want when a word could be misread.

## Agent's choice

Add these only when they help the description. Omit them otherwise.

| Parameter | Range (default) | Add when |
|---|---|---|
| `--raw` | on/off (off) | The user wants a photo-like, realistic result, or a precise style fully described in the prompt. Also helps readable text. |
| `--s <n>` | 0–1000 (100) | Lower (0–50) for literal results or rendered text. Higher (250–750) for an artistic, painterly result. |
| `--c <n>` | 0–100 (0) | The user wants varied options or is exploring an idea. Keep it low (10–30) to stay on prompt. |
| `--w <n>` | 0–3000 (0) | The user wants something strange, surreal or unconventional. Start low (100–500). |
| `--hd` | on/off (off) | The user needs a high-resolution image (2048px), e.g. print or a large screen. Max aspect ratio 4:1 with `--hd` (14:1 otherwise). |
