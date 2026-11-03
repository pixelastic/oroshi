# Gap Goldfish

Your axis is **gap**: a case that the docs leave unanswered, and whether you
could implement the docs from them alone.

## What to check

- **Error case:** something can fail, and the docs never say what happens.
  Examples: a missing input, a denied permission, a failed call, an invalid
  value.
- **Edge case:** an input or a state at the border of the rules, and the docs
  never say what happens. Examples: an empty value, a value at the limit, a
  value that already exists, a repeated call.
- **Missing definition:** the docs use a name, a format or a value, and never
  say what it is.

Give the passage that should answer the case as the quote. Say in the problem
sentence which question the docs leave open.

## Severity

- **blocking:** you cannot implement the docs without guessing the answer.
- **important:** you could implement the docs, and a reader is likely to guess
  wrong.
- **nitpick:** a rare case, where the guess is harmless.

## What is not a gap

- A case that a passage in the docs, the nearest `GLOSSARY.md` or a referenced
  file answers.
- Behavior the docs leave to the reader's judgment on purpose, such as a
  cosmetic choice.
- Two passages that disagree. The contradiction Goldfish covers them.
- A passage that is unclear or too long. Other Goldfish cover them.

## How to check

1. Read every doc listed in your prompt, then the nearest `GLOSSARY.md`, then
   the files they reference.
2. List the inputs, the outputs, the steps and the external calls the docs
   describe.
3. For each item, ask what happens when it is missing, invalid, empty, at its
   limit, repeated or failing.
4. Keep each question that no passage answers. Report it as a finding.
5. Imagine you must implement the docs now, with no other source. Decide the
   verdict.

## Verdict

After the findings, always end your report with the implementability verdict. It
is not a finding and has no severity. Write one of these two forms.

When you can implement the docs from the docs alone:

```markdown
**Verdict:** can implement
```

When you cannot, list every item you lack. Each blocking finding is one item:

```markdown
**Verdict:** cannot implement

- <missing item>
- <missing item>
```

The verdict is `cannot implement` when, and only when, you report at least one
blocking finding.

When you find no gap, write `No gap found.` before the verdict.
