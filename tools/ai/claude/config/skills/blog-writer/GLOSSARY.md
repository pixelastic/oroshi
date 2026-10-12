# Blog Writer

Vocabulary for the `blog-writer` skill: turning real work into a short technical article, from interview to approved Markdown draft.

## Language

**Reader**:
The person the article addresses directly.
_Avoid_: persona, audience, target, public

**Voice**:
How the text sounds, at the level of words and sentences, including its tone.
_Avoid_: tone, writing style, register

**Structure**:
The skeleton of an article: which parts it has and in what order.
_Avoid_: outline, plan, format, layout

**Style**:
The combination of **Voice** and **Structure**.
_Avoid_: voice (alone), tone, writing style, template

**Source material**:
The code or artifact the user points to, from which the skill gathers facts before asking questions.
_Avoid_: input, context, reference

**Interview**:
The exchange where the skill asks the user one question at a time, to learn what the **Source material** cannot tell.
_Avoid_: questionnaire, brainstorm, intake, Q&A

**Brief**:
The summary of an article, validated by the user after the **Interview** and before any drafting.
_Avoid_: summary, plan, spec, outline

**Article folder**:
The directory that holds everything about one article: its **Brief**, the interview verbatim, the **Draft** and its images.
_Avoid_: session, workspace, project, draft folder

**Draft**:
The Markdown text of an article, from first write until the user approves it.
_Avoid_: version, copy, article

**Lint**:
The deterministic checks run on a **Draft**: the Vale `blog` profile and the word limit.
_Avoid_: validation, check, proofreading

**Reviewer**:
A sub-agent that checks a **Draft** against one axis: the **Voice**, the **Structure** or the **Reader**.
_Avoid_: judge, critic, validator, axis reviewer

**Improvement**:
A finding that a **Reviewer** judges worth fixing before the user reads the **Draft**.
_Avoid_: issue, problem, error, major

**Nitpick**:
A finding that a **Reviewer** reports but that is too small to justify an edit.
_Avoid_: minor, suggestion, style issue

## Relationships

- A **Style** is exactly one **Voice** plus one **Structure**
- The **Reader** is not part of the **Style**, but it is a review axis
- An article has exactly one **Brief** and exactly one **Article folder**
- An **Article folder** holds one **Brief** and zero or more **Drafts**
- No **Draft** is written without a validated **Brief**
- A **Brief** contains the outline of its article, which follows the **Structure**
- An **Interview** starts from the **Source material** and asks only what it cannot answer
- Three **Reviewers** run in parallel on one **Draft**: one for the **Voice**, one for the **Structure**, one for the **Reader**
- A **Reviewer** returns zero or more findings, each one an **Improvement** or a **Nitpick**
- Only **Improvements** are kept; **Nitpicks** are hidden
- The **Lint** checks what a machine can verify; the **Voice**, **Structure** and **Reader** files hold only what the **Lint** cannot verify
- The **Lint** reuses the severity levels of Prose Linting (**Error**, **Warning**, **Suggestion**) and does not redefine them

## Flagged ambiguities

- "persona", "audience" and "target" were used for the same idea — resolved: the single term is **Reader**.
- "tone" was attributed to the **Structure** side — resolved: tone belongs to the **Voice**.
- "plan" and "outline" were used for the whole article summary — resolved: the **Brief** is the validated summary, and the outline is one part of it.
- "suggestion" could name a **Reviewer** finding — resolved: **Suggestion** is reserved for the **Lint** severity; **Reviewer** findings are an **Improvement** or a **Nitpick**.

## Example dialogue

> **Dev:** "The **Draft** went over the word limit. Do I trim it?"
> **Domain expert:** "No — go back to the **Brief**. If the content does not fit, split it into several articles, each with its own **Brief** and **Article folder**."
>
> **Dev:** "The **Voice** **Reviewer** found nothing. Is that a failure?"
> **Domain expert:** "No — a **Reviewer** may report nothing. Only **Improvements** reach you; **Nitpicks** stay hidden."
