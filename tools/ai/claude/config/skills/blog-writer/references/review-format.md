# Review Format

Format of the findings that a Reviewer returns. Each Reviewer checks one axis: the Voice, the Structure or the Reader.

## Rules

- Read the Draft in full. Check it against your axis only.
- Do not edit the Draft. Report findings only.
- Report nothing when the Draft has nothing to fix on your axis. An empty report is a valid result. Do not invent findings to fill the report.
- Do not report what the Lint already checks: the Vale `blog` rules and the word limit.
- Report one finding per place. Do not repeat the same finding at each occurrence: quote the first one and say how many more exist.

## Finding

One line per finding, in this shape:

`<class> | "<quote>" | <explanation> | <fix>`

- **class**: `improvement` or `nitpick`.
  - `improvement`: worth fixing before the user reads the Draft. The Draft is clearly worse for the Reader if left alone.
  - `nitpick`: real but too small to justify an edit.
- **quote**: the exact words from the Draft, 20 words at most. The skill finds the place from the quote.
- **explanation**: why it breaks a rule of your reference, in 20 words at most.
- **fix**: the concrete change, in 20 words at most.

## Out of axis

When a finding is real but belongs to another axis, start the line with `out of axis:` before the class:

`out of axis: <class> | "<quote>" | <explanation> | <fix>`

Do not drop it. The skill decides what to do with it.

## Empty report

When there is nothing to report, return exactly: `No findings.`

## Length

Stay under 200 words in total.
