# Confluence

The commands that let a shell or an agent read Confluence pages. It follows the
[API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

This glossary defines only what is custom to Confluence. The base verbs (`list`,
`list-raw`, `search`, `read`, `create`, `update` and `delete`) are defined in
the API glossary and are not defined again here. Do not add an entry for a base
verb, even for a new command. The behavior of a command belongs in the header of
its wrapper.

## Language

### Authentication

**Token**:

The Atlassian API token (`CONFLUENCE_TOKEN`) of this **Key API**, sent with the
**Email** as Basic auth. There is no **Login**.

_Avoid_: key, password, OAuth token

**Email**:

The Atlassian account email (`CONFLUENCE_EMAIL`) that owns the **Token**.

_Avoid_: user, username, login

**Cloud ID**:

The identifier of the Atlassian site (`CONFLUENCE_CLOUD_ID`), used to build the
gateway URL of every call.

_Avoid_: tenant ID, site ID, instance

**Domain**:

The host of the Atlassian site (`CONFLUENCE_DOMAIN`), used to build the URL of a
**Page**.

_Avoid_: host, site, base URL

### Entities

**Page**:

A document of a **Space**, identified by a numeric ID. It has a **Fixed
schema**: a title and a **Body**. It has no **Anchor**.

_Avoid_: article, doc, content

### Service terms

**Space**:

A named area of the site that holds **Pages**, identified by `spaceId` in the
output of a **Page**.

_Avoid_: folder, project, wiki

**Body**:

The content of a **Page**, in the storage format of Confluence (HTML with
macros). The `markdown` key of a **Page** holds it.

_Avoid_: content, text, HTML

**Page ID**:

The value that `read` takes: a numeric ID, or the URL of a **Page**, from which
the ID is extracted.

_Avoid_: page URL, content ID

## Flagged omissions

There is no `create`, `update` or `delete` for a **Page**. The scope is
read-only on purpose, so that an agent cannot change the documents of a team.

## Relationships

- A **Space** contains zero or more **Pages**
- A **Page** belongs to exactly one **Space**
- A **Page** has exactly one **Body**
- Every command uses the same **Email**, **Token**, **Cloud ID** and **Domain**

## Flagged ambiguities

- "id" can be a numeric ID or a URL — resolved: `read` takes both, as a **Page
  ID**.
- The variable names carried an `OROSHI_` prefix in the first version —
  resolved: the variables are `CONFLUENCE_EMAIL`, `CONFLUENCE_TOKEN`,
  `CONFLUENCE_CLOUD_ID` and `CONFLUENCE_DOMAIN`.
- The glossary of the API calls Confluence an **OAuth API** — resolved: it is a
  **Key API**, since it authenticates with an **Email** and a **Token**.

## Example dialogue

> **Dev:** "I have a link to a **Page**. Do I extract the number myself?"
> **Domain expert:** "No — `confluence-page-read` takes the link as a **Page
> ID** and extracts the number." **Dev:** "Where does the link in the output
> come from?" **Domain expert:** "It is built from the **Domain** and the path
> that the API returns." **Dev:** "And to change the **Page**?" **Domain
> expert:** "You can't. This service is read-only."
