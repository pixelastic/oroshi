# Notion

The commands that let a shell or an agent read and write Notion data. It follows
the [API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

This glossary defines only what is custom to Notion. The base verbs (`list`,
`list-raw`, `search`, `read`, `create`, `update` and `delete`) are defined in
the API glossary and are not defined again here. Do not add an entry for a base
verb, even for a new command. The behavior of a command belongs in the header of
its wrapper.

## Language

### Authentication

**Token**:

The API token of this **Key API**: `NOTION_TOKEN`, or `NOTION_TOKEN_<ACCOUNT>`
for another account chosen with `--account`. There is no **Login**.

_Avoid_: key, secret, integration token

### Entities

**Page**:

A Notion page, identified by an ID, which is also a row when its **Parent** is a
**Database**. It has no **Anchor**, and has an **Open schema**.

_Avoid_: row, entry, sub-page, document, note

**Database**:

A set of **Pages** that share the same **Properties**, identified by an ID. It
always has a **Page** as its **Parent**, has no **Anchor**, and has an **Open
schema**.

_Avoid_: table, collection

**Icon**:

The emoji or the image URL shown next to the title of a **Page**. Its **Anchor**
is `--pageId`, and it has a **Fixed schema**: one value.

_Avoid_: image, logo, thumbnail, avatar

### Custom verbs

**append**:

Adds some **Content** at the end of a **Page**, and keeps the existing
**Content**.

_Avoid_: add, push

**replace**:

Swaps one passage of the **Content** of a **Page** for another passage.

_Avoid_: edit, swap

**remove**:

Deletes one passage of the **Content** of a **Page**.

_Avoid_: delete, cut

**generate**:

Sets the **Icon** of a **Page** from the first image of its **Content**.

_Avoid_: auto, create

### Service terms

**Property**:

A named and typed value of a **Page**, defined by the **Database** that holds
it.

_Avoid_: field, column, attribute

**Content**:

The body of a **Page**, written as markdown, and given with `--content` or
`--content-file`.

_Avoid_: body, text, markdown

**Parent**:

The **Page** or the **Database** that holds a **Page**, or the **Page** that
holds a **Database**.

_Avoid_: container, folder, owner

**Trash**:

The state of a **Page** or a **Database** that `delete` put away, and that
Notion can restore.

_Avoid_: archive, removed, deleted

**Filter**:

The JSON object of conditions on **Properties**, given with `--filter`, that
keeps only some **Pages** of a **Database**.

_Avoid_: query, where

**Sort**:

The JSON object that orders the **Pages** of a **Database** by their
**Properties**, given with `--sort`.

_Avoid_: order, orderBy

## Flagged omissions

- There is no `block` entity on purpose. **Content** is read and changed as a
  whole, so images and tables are out of reach until a use case needs them.
- `search` looks at titles only, not at the **Content** of **Pages**.
- A **Database** cannot be created at the root of the workspace. Its **Parent**
  is required.

## Relationships

- A **Page** has exactly one **Parent**, a **Page** or a **Database**
- A **Database** has exactly one **Parent**, a **Page**
- A **Database** contains zero or more **Pages**, which share its **Properties**
- A **Page** has zero or more **Properties**, and one **Content**
- A **Page** has at most one **Icon**
- `list` shows the **Pages** under a **Parent**. **Filter**, **Sort** and
  `--limit` choose which ones, in which order, and how many
- Every command uses one **Token**, the one of the account it runs against

## Flagged ambiguities

- "sub-page" and "row" both name a **Page** — resolved: a sub-page is a **Page**
  whose **Parent** is a **Page**, and a row is a **Page** whose **Parent** is a
  **Database**. Both are **Pages**.
- `list` and `search` both find **Pages** — resolved: `search` looks at the
  titles of the whole workspace, and `list` shows what is under one **Parent**.
- `read`, `create`, `update` and `delete` of a **Database** act on its
  **Properties**, while `list` acts on the **Pages** it contains — resolved: the
  first set changes the structure, the second reads the content.
- `delete` suggests a definitive removal — resolved: it puts the **Page** or the
  **Database** in the **Trash**, with no check on its content, and Notion can
  restore it.
- The **Icon** is part of a **Page** in the Notion API — resolved: `page read`
  does not return it, `page update` ignores it, and only the `icon` commands
  change it.

## Example dialogue

> **Dev:** "I want the list of the meetups in my **Database**. Which command?"
> **Domain expert:** "Run `notion-database-list-raw` with the **Database** ID.
> Add a **Filter** to keep only some **Pages**, and `--limit` to cap them."
> **Dev:** "And if I only know its name?" **Domain expert:** "Run
> `notion-database-search` with the name. It looks at titles in the whole
> workspace." **Dev:** "I spotted a typo in a **Page**. Do I resend all its
> **Content**?" **Domain expert:** "No — run `notion-page-replace` with the old
> and the new passage." **Dev:** "I deleted a **Page** by mistake." **Domain
> expert:** "It is in the **Trash**. Restore it from Notion."
