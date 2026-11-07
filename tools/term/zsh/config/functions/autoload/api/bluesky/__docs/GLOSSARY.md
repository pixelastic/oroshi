# Bluesky

The commands that let a shell or an agent publish and manage Bluesky posts. It
follows the [API glossary](../../../../../../../../../docs/api/GLOSSARY.md), and
defines only the words of this service.

This glossary defines only what is custom to Bluesky. The base verbs (`list`,
`list-raw`, `read`, `create` and `delete`) are defined in the API glossary and
are not defined again here. Do not add an entry for a base verb, even for a new
command. The behavior of a command belongs in the header of its wrapper.

## Language

### Authentication

Bluesky is an **OAuth API**: `bluesky-login` is its **Login**, and it saves one
tokens file for each **Account**.

**Account**:

The local label of a tokens file, `default` or `test`, chosen with `--account`.
It is not the identity that signs in to the browser, which is the **DID**.

_Avoid_: user, profile, login name

**Handle**:

The readable name of an identity, such as `pixelastic.bsky.social`, which its
owner can change.

_Avoid_: username, account, user id

**DID**:

The decentralized identifier of an identity, such as `did:plc:z72i7hdynmk6r…`,
which is unique and never changes.

_Avoid_: user id, handle, account id

**PDS**:

The Personal Data Server that stores the **Records** of a **DID** and receives
the calls of the API.

_Avoid_: server, host, instance, bsky.social

### Entities

**Post**:

A **Record** of text, at most 300 graphemes and 3000 bytes, published by a
**DID**. It has no **Anchor**, and has a **Fixed schema**: text, **Facets**, at
most one **Embed**, and a **Parent** with its **Thread root** when it replies.
Only the text is required.

_Avoid_: skeet, tweet, message, status

### Custom verbs

**lint**:

Checks a **Draft** with the parser and the validation of `create`, and publishes
nothing. Its **Draft** is a named argument instead of an id (breaks the first
guideline of the custom verbs: the id of the entity is a positional argument,
because no **Post** exists yet). Its output follows the
[lint output](../../../../../../../../../docs/toolchain/lint-output.md) of the
toolchain, and not the API documentation.

_Avoid_: check, validate, verify

### Service terms

**AT URI**:

The permanent address of a **Record**, of the form
`at://<DID>/<collection>/<rkey>`.

_Avoid_: URI, link, URL

**Record**:

A JSON datum stored in the repository of a **DID**, identified by an **AT URI**.

_Avoid_: document, object, entry

**CID**:

The content hash of a **Record**, which a **Parent** or a **Thread root**
carries next to its **AT URI**.

_Avoid_: hash, checksum, digest

**Facet**:

The annotation of a range of bytes of the text of a **Post**: a link, a mention
or a hashtag.

_Avoid_: link, tag, annotation, markup

**Embed**:

The single content attached to a **Post** beside its text: up to four images, or
a link card.

_Avoid_: attachment, media, card, preview

**Blob**:

A binary file uploaded to the **PDS** and referenced by a **Record**.

_Avoid_: upload, file, media, image

**Parent**:

The **Post** to which a **Post** replies directly.

_Avoid_: reply target, previous

**Thread root**:

The first **Post** of the **Thread** to which a **Post** belongs.

_Avoid_: root, origin, first post

**Thread**:

A series of **Posts** published together with `--thread`, each replying to the
previous one.

_Avoid_: chain, conversation

**Draft**:

The Markdown file that holds one or more **Posts**, the source of `create` and
`lint`.

_Avoid_: input, source, file

## Relationships

- An **Account** matches exactly one **DID** after its **Login**
- A **DID** has exactly one **Handle** at a time, and exactly one **PDS**
- A **PDS** stores zero or more **Records** of a **DID**
- A **Post** is exactly one **Record**, identified by one **AT URI**
- A **Post** has zero or more **Facets**, and at most one **Embed**
- An **Embed** of images references one to four **Blobs**
- A **Post** has at most one **Parent**, and one **Thread root** when it has a
  **Parent**
- A **Thread** contains one or more **Posts**, each one the **Parent** of the
  next
- A **Draft** holds one or more **Posts**
- Every command uses one **Account**, `default` unless `--account` says
  otherwise

## Flagged ambiguities

- "account" named both the local label and the identity that signs in —
  resolved: the **Account** is the local label, the **Handle** is the readable
  name, and the **DID** is the identity.
- **Parent** and **Thread root** are the same **Post** when a **Post** replies
  to the first **Post** of a **Thread** — resolved: they stay two terms, because
  a reply carries both.
- An **AT URI** and the `bsky.app` URL of a **Post** name the same **Post** —
  resolved: the **AT URI** is the address, and the commands accept the URL as an
  equivalent form.

## Example dialogue

> **Dev:** "Which **Account** does `bluesky-post-create` use?" **Domain
> expert:** "The `default` one, unless you pass `--account test`." **Dev:**
> "Does the **Account** hold my **Handle**?" **Domain expert:** "No — it only
> names a tokens file. The **Handle** can change, and the **DID** stays the
> same." **Dev:** "My **Draft** has three dashes between two **Posts**."
> **Domain expert:** "Pass `--thread`. The first **Post** is the **Thread
> root**, and each one is the **Parent** of the next." **Dev:** "How do I check
> the length before publishing?" **Domain expert:** "Run `bluesky-post-lint` on
> the **Draft**. It publishes nothing."
