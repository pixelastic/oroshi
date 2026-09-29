# Comments

## All comments

- Say only what the code shows. If you do not know why, do not guess.
- Write one topic per comment.
- When a fact explains another one, link them in one sentence (because, so, but). If a fact explains nothing, remove it rather than invent a link.
- When a sentence needs more than one subordinate clause, split it into a bullet list.
- For an action, make the actor the subject and the action the verb. For a definition, "is" is fine (`path is the game folder`).
- Call each thing by its name, not by a vague reference. Name the variables the comment talks about (`gamesToPush`, not "both lists").
- When the code changes a default behavior, say what would happen without it.
- Do not restate in prose what the code shows at a glance, like default option values. The prose goes stale when the code changes.
- Write correct grammar. "We" and "…" are fine. Remove filler that tells the reader nothing ("This can be confusing, but is expected").

## Inline comments

These rules apply to comments inside a function body.

- Structure a comment of several sentences in three parts, and mark each one:
  - Situation: "When…" or "If…". Use the present perfect for what happened before this code runs.
  - Steps: "first", "then", in the order the code runs them. Put the "because" inside the step it justifies.
  - Outcome: "So…" when it works, "But…" when a gap remains.
- Use the imperative to announce a step (`Free the query buffer`).
- Use the present tense for what is true at this line, and "will" for what happens later in the run.
- Labels are fine for section headers (`Users: table with one row per account`), data shapes, test fixtures and short cause-effect notes (`Read as a Buffer: saves are binary`).
- A test setup comment states the initial state in the plain present, without "moved", "still" or "already" (`report.pdf is in archive/ locally and in inbox/ on the server`).

## Function docs

These rules apply to the doc block of a function: JSDoc, docstring, doc comment or function header comment.

- Use the verb mood of the other function docs in the repo.
- Write a one-line summary that stands alone. Do not start with "This function" or repeat the name.
- Describe the contract: inputs, outputs and effects.
- Say when to choose each option of the function.
- Document the edge cases the code handles: dry-run and other global flags, empty input, missing files.
- State preconditions ("Run after pullSaves"). Do not describe what the callers do: their code changes, and the doc then goes stale.
- Do not state the obvious ("false otherwise", "Returns nothing otherwise").
