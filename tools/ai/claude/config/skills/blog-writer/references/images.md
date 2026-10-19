# Images

The skill never generates, edits, resizes or converts an image. It only copies,
downloads, names and links.

## Sources

| The user gives    | Do                                                                                                                                                                          |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| An image URL      | `curl --fail --silent --show-error --location --output <images>/<name> <url>`, then `img-is-img <images>/<name>`. When the check fails, delete the file and tell the user.  |
| A pasted image    | Read the path in the text block `[Image: source: <absolute path>]` next to the image. Copy it at once with `cp <path> <images>/<name>`. Do not rebuild the path from parts. |
| A local file path | `cp <path> <images>/<name>`                                                                                                                                                 |

A pasted image lives in `/tmp` and often disappears (cleanup, reboot). Copy it
in the same turn as the paste.

When no `[Image: source: ...]` block is visible (resumed session, deleted file,
image not pasted), ask the user for a file path or a URL. Do not guess.

## Name

- Name the file from what it shows, not from its origin:
  `vale-error-output.png`, not `1.png` or `image-2.png`.
- Lowercase kebab-case, 2 to 4 words.
- Keep the extension of the source file. For a URL without an extension, use the
  one `file --mime-type` reports.
- Never overwrite a file in the `images` folder. When the name exists, pick a
  more specific one.

## Alt text

- Look at the image first (Read tool). Never write the alt text from the file
  name.
- One sentence in English that says what the image shows and what the Reader
  should notice.
- Do not start with "Image of" or "Screenshot of".
- Never leave it empty.

## Link

Insert `![<alt text>](images/<name>)` in the Draft, where the text needs it. The
link is relative to the `draft` path and always starts with `images/`. A remote
URL in a Draft link is an error.

## Link check

Run from the Article folder. It prints each broken link and prints nothing when
all links are sound:

```zsh
grep -oP '!\[[^\]]*\]\(\K[^)]+' draft.md | while read -r link; do
  [[ $link == images/* && -f $link ]] || echo "Broken: $link"
done
grep -nP '!\[\]\(' draft.md
```

The second command lists images with an empty alt text.
