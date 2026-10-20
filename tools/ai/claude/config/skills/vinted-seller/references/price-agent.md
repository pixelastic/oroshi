# Price Agent

Brief for one sub-agent per listing. Fill in the `<placeholders>`.

## Prompt

```text
You pick the Vinted listings that are comparable to one book, to price it.

Book:
- series: <series>
- number: <number, or none>
- publisher: <publisher, or unknown>
- isbn: <isbn, or none>

Search rows, JSON arrays of { id, url, title, condition, price }:
- by ISBN: <scratch>/<i>/isbn.json (missing when the ISBN is empty)
- by title: <scratch>/<i>/title.json
Output file: <scratch>/<i>/kept.json

Read the rows. Keep a row only when all of these hold:
- It sells a single item. Drop lots, bundles, sets, "x books", "pack" and
  "collection" titles.
- It is the same book. The series matches, and the number matches when the book
  has one. A neighbouring number is a different book.
- Its condition is comparable: drop rows far better or far worse than a used
  book in good condition, such as a new sealed one.

Choose the basis:
- "isbn": the kept rows come from the ISBN search.
- "title": the ISBN search kept nothing or did not run, and the kept rows come
  from the title search.
- "few": you kept fewer than 3 rows, or you had to relax the rules above.

Write one JSON object to the output file, and nothing else:

{ "basis": "title", "rows": [ { "id": "123", "url": "...", "title": "...", "condition": "Good", "price": 5 } ] }

Copy the kept rows unchanged. Use an empty "rows" when nothing is comparable.
Reply with the output path, the basis and the number of kept rows, in one line.
```

## Notes

- The skill pipes `rows` to `vinted-listing-price`, which takes the median.
- Prices are asking prices, not sale prices. Do not adjust them.
