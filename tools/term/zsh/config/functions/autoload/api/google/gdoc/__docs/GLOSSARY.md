# Google Docs

The commands that let a shell or an agent read Google Docs. It follows the
[API glossary](../../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

## Language

### Authentication

**Account**:

The Google account whose OAuth tokens a command uses. This is an **OAuth API**,
and its **Login** is `google-login`, shared with Gmail. `--account` selects the
account, and the default account is used otherwise.

_Avoid_: profile, user

### Entities

**Document**:

A Google Doc, identified by an ID found in its URL. It has no **Anchor**, and
has a **Fixed schema**. Its commands accept the URL or the ID. The content of a
**Document**, when a command creates one, is a file given as the positional
argument (`.md` or `.docx`), not a flag.

_Avoid_: doc, file, page

**Comment**:

A remark that a reader leaves on a **Document**, with its replies. Its
**Anchor** is `--documentId`, and it has a **Fixed schema**.

_Avoid_: note, annotation, thread

### Service terms

**Tab**:

One of the named sections of a **Document**. Each **Tab** has its own body. A
`?tab=` in the URL selects it, and `read` takes the first **Tab** otherwise.

_Avoid_: page, section, sheet

**Markdown**:

The text of one **Tab**, converted from the structure of the **Document**:
headings, lists, links, tables and images.

_Avoid_: text, content, export

### Custom verbs

**download**:

Saves the **Markdown** of a **Document** in a folder of the current directory,
named after its title, with the images of the **Document** next to it as
`image-N.png`. It prints the path of the folder.

_Avoid_: export, fetch, save

## Relationships

- A **Document** contains one or more **Tabs**, which can be nested
- A **Document** has zero or more **Comments**
- A **Comment** is left on one **Document**
- Every command uses the tokens of one **Account**

## Flagged ambiguities

- "doc" can mean the Google Doc or the JSON the API returns — resolved: the
  entity is a **Document**.
- `read` prints the **Markdown** of a single **Tab**, not of the whole
  **Document**.
