# Airtable

The commands that let a shell or an agent read and write Airtable data. It follows the [API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and defines only the words of this service.

## Language

### Authentication

**Token**:
The single API token (`AIRTABLE_TOKEN`) of this **Key API**, with the read and write scopes. There is no **Login**.
_Avoid_: key, read token, write token

### Entities

**Base**:
An Airtable database, identified by an ID starting with `app`. It has no **Anchor**, and has a **Fixed schema**.
_Avoid_: database, workspace, app

**Table**:
A named set of **Records** sharing the same **Fields**, inside a **Base**. Its **Anchor** is `--baseId`, and it has a **Fixed schema**.
_Avoid_: sheet, collection, tab

**Record**:
A row of a **Table**, identified by an ID starting with `rec`. Its **Anchors** are `--baseId` and `--tableId`, and it has an **Open schema**.
_Avoid_: row, entry, item, line

**Attachment**:
A file stored in a **Field** of type Attachment, identified by an ID starting with `att`. Its **Anchors** are `--baseId`, `--tableId` and `--recordId`.
_Avoid_: file, upload, asset, image

### Custom verbs

**add**:
Uploads a local file as a new **Attachment** of a **Field**, and keeps the existing ones.
_Avoid_: upload, attach

**remove**:
Deletes some **Attachments** of a **Field**, given by `--attachmentId`, or all of them with `--all`.
_Avoid_: delete, detach

**replace**:
Uploads a local file into a **Field**, and keeps only that new **Attachment**.
_Avoid_: swap, overwrite

### Service terms

**Field**:
A column of a **Table**, with a name and a type, holding one value in each **Record**.
_Avoid_: column, property, attribute

**Content**:
The JSON object of **Fields** that `create` and `update` send, given inline or with `--data-file`.
_Avoid_: payload, body

**Formula**:
The Airtable formula that `search` takes as its positional argument, to keep the matching **Records**.
_Avoid_: filter, query

**Table ID**:
The value of `--tableId`, which is a table ID starting with `tbl` or a **Table** name, forwarded as given.
_Avoid_: table name, table

## Relationships

- A **Base** contains one or more **Tables**
- A **Table** contains zero or more **Records** and one or more **Fields**
- A **Record** holds at most one value per **Field**
- A **Field** of type Attachment holds zero or more **Attachments**
- Every command uses the same **Token**

## Flagged ambiguities

- "app" names the ID of a **Base** (`appXXX`) in the Airtable API — resolved: the concept is a **Base**, and `app` is only the prefix of its ID.
- "file" is the local file passed to `--file` — resolved: it becomes an **Attachment** once Airtable stores it.
- "table" can be an ID or a name — resolved: `--tableId` takes both, as a **Table ID**.
- `update` of a **Record** cannot change an **Attachment** — resolved: its **Content** holds regular **Fields** only, and the custom verbs change **Attachments**.

## Example dialogue

> **Dev:** "I want to add a logo to this **Record**. Do I call `airtable-record-update`?"
> **Domain expert:** "No — the **Content** only holds regular **Fields**. Call `airtable-attachment-add` with the **Record** ID."
> **Dev:** "And to swap the logo?"
> **Domain expert:** "Call `airtable-attachment-replace`. It keeps only the new **Attachment**."
> **Dev:** "Which **Base** do I pass?"
> **Domain expert:** "Pass its full `app` ID. `airtable-base-list` shows the IDs."
