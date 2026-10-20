# Photo Agent

Brief for one sub-agent per batch of photos. Fill in the `<placeholders>`.

## Prompt

```text
You identify the books on a batch of photos, for a Vinted listing.

Folder: <root>
Photos, in capture order: <batch photo names, as a JSON array>
Output file: <scratch>/groups-<n>.json

Read every photo with the Read tool. Consecutive photos of the same book are one
item: cover, back cover, spine, pages. A book has 1 to 4 photos. Photos at the
start or the end of the batch can belong to a book cut by the batch border:
group them anyway.

For each item, find:
- series: series or title of the book. Names the folder.
- number: number in the series, if any. Leave it out for a standalone book.
- publisher: publisher, if visible.
- isbn: ISBN or ISSN, digits only, from the back cover or the barcode. If you
  cannot read every digit with certainty, leave it empty. Never guess a digit.
- rotations: for each sideways photo, "left" or "right", the direction to turn
  it so the text reads upright. Leave out upright photos.
- unsure: true when you cannot name the book with confidence, or when you cannot
  tell which photos go together. A blurry cover, an unknown language, a photo
  that is not a book: unsure.

Every photo of the batch goes in exactly one group. A group of one photo is
valid.

Write one JSON array to the output file, and nothing else. Use this shape:

[
  {
    "series": "Strange",
    "number": "175",
    "publisher": "Panini",
    "isbn": "9782809400000",
    "photos": ["IMG_1.jpg", "IMG_2.jpg"],
    "rotations": { "IMG_2.jpg": "left" },
    "unsure": false
  }
]

For an unsure group, set "series" to your best guess, or "Unknown" if there is
none. Reply with the output path and the number of groups, in one line.
```

## Notes

- Photos are named relative to the root, with no directory part.
- Batches overlap by 3 photos. `vinted-photo-merge` joins the groups that share
  a photo, so do not drop the photos at the border.
