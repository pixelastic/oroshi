# Airtable

Helpers that let a shell or an agent read and write Airtable data. Every helper is named `airtable-<entity>-<action>`, and the entity is never implicit.

## Language

**Base**:
An Airtable database, identified by an ID starting with `app`.
_Avoid_: database, workspace, app

**Base alias**:
A short name that resolves to the ID of one **Base**, through the environment variable `AIRTABLE_BASE_<NAME>`.
_Avoid_: base name, base shortcut

**Table**:
A named set of **Records** sharing the same **Fields**, inside a **Base**.
_Avoid_: sheet, collection, tab

**Record**:
A row of a **Table**, identified by an ID starting with `rec`.
_Avoid_: row, entry, item, line

**Field**:
A column of a **Table**, with a name and a type, holding one value in each **Record**.
_Avoid_: column, property, attribute

**Attachment**:
A file stored in a **Field** of type Attachment, identified by an ID starting with `att`.
_Avoid_: file, upload, asset, image

**Read token**:
The API token (`AIRTABLE_TOKEN_READ`) that allows reading **Records** and listing **Bases**.
_Avoid_: readonly token

**Write token**:
The API token (`AIRTABLE_TOKEN_WRITE`) that allows creating and changing **Records** and **Attachments**.
_Avoid_: admin token

## Relationships

- A **Base** contains one or more **Tables**
- A **Table** contains zero or more **Records** and one or more **Fields**
- A **Record** holds one value per **Field**, which can be empty
- A **Field** of type Attachment holds zero or more **Attachments**
- A **Base alias** resolves to exactly one **Base**
- Reading helpers use the **Read token**, writing helpers use the **Write token**

## Flagged ambiguities

- "app" names the ID of a **Base** (`appXXX`) in the Airtable API — resolved: the concept is a **Base**, and `app` is only the prefix of its ID.
- "file" is the local file passed to `--file` — resolved: it becomes an **Attachment** once Airtable stores it.

## Example dialogue

> **Dev:** "I want to add a logo to this **Record**. Do I call `airtable-record-write`?"
> **Domain expert:** "No — `--fields` only holds regular **Fields**. Call `airtable-attachment-add` with the **Record** ID."
> **Dev:** "And to swap the logo?"
> **Domain expert:** "Read the **Record** to get the `att` ID of the current **Attachment**, then call `airtable-attachment-replace`."
> **Dev:** "Which **Base** do I pass?"
> **Domain expert:** "Use a **Base alias** such as `DevRel`, or the full `app` ID."
