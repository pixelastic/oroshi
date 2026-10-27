# Gmail

The commands that let a shell or an agent read and interact with Gmail. It
follows the [API glossary](/docs/api/GLOSSARY.md), and defines only the words of
this service. Its words are the words of the Gmail API.

## Language

### Authentication

**Account**:

The Google account whose OAuth tokens a command uses. This is an **OAuth API**,
and its **Login** is `google-login`, shared with Google Docs. `--account`
selects the account, and the default account is used otherwise.

_Avoid_: profile, user

### Entities

**Thread**:

A conversation: an array of **Messages**. The `id` that the commands print as
`threadId` is the id of the **Thread**. It has no **Anchor**, and has a **Fixed
schema**. A **Thread** with one **Message** has the same id as that **Message**.

_Avoid_: mail, email, conversation

**Message**:

One e-mail inside a **Thread**, sent or received. A **Message** is not an
**Entity** of its own, and no listing prints it. A **Thread** is read as a
whole: `read` prints all its **Messages**. Only `messageId` targets a single
**Message**, for `attachment download`. `rfcMessageId` is the `Message-ID`
header of a **Message**, not its id.

_Avoid_: mail, email

`list-raw` prints the **Threads** of the inbox, as `▮` lines:
`threadId▮date▮count▮authors▮subject▮snippet▮unread`. `date` is the date of the
last **Message**, `count` the number of **Messages**, and the authors are
separated by `▯`. Unread **Threads** come first, then the newest first.

**Attachment**:

A file carried by a **Message**. It is not an **Entity** of its own: `read`
lists the attachments of each **Message** (`partId`, `filename`, `mimeType`,
`size`), and `download` saves one of them. A part id is only unique inside its
**Message**, so `download` takes the `messageId`, not the `threadId`.

_Avoid_: file, document

**Draft**:

A **Message** that is written and not sent yet, saved in Gmail. It is either
new, or a reply to the last **Message** of a **Thread**. A reply **Draft** holds
only the text of the user, and no copy of the previous **Message**.

`gmail-draft-read draftId` prints one **Draft** as JSON: `draftId`, `threadId`,
`messageId`, `from`, `to`, `subject`, `body` and `attachments`. Each
**Attachment** has a `partId`, a `filename`, a `mimeType` and a `size`, never
its bytes.

_Avoid_: unsent mail, unsent email, reply

### Verbs

**`download`**:

A **Custom verb** of the `attachment` entity:
`gmail-attachment-download messageId --partId <id>` saves one **Attachment** and
prints the path of the saved file. `--out` is an existing directory (the file
keeps its remote filename), a file path, or nothing (the current directory).

### Service terms

**Inbox**:

The Gmail label `INBOX`. The default list of **Threads** is the **Inbox**.

_Avoid_: mailbox, folder

**Alias**:

The e-mail addresses of an **Account** that the user can send from. A reply to
all removes them from its recipients, so that the user does not reply to
themselves.

_Avoid_: identity, sender, address

## Relationships

- A **Thread** contains one or more **Messages**
- A **Message** carries zero or more **Attachments**
- The **Inbox** holds zero or more **Threads**
- Every command uses the tokens of one **Account**
- An **Account** has one or more **Aliases**
- A **Draft** replies to the last **Message** of one **Thread**, or to none
- A reply **Draft** is sent from one **Alias** of the **Account**

## Flagged ambiguities

None. The words **Thread** and **Message** are the words of the Gmail API, and
`--threadId` and `--messageId` each take the id of the matching entity.
