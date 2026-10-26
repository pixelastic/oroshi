# Gmail

The commands that let a shell or an agent read Gmail, and write **Drafts**. No
command sends a **Mail**. It follows the [API glossary](/docs/api/GLOSSARY.md),
and defines only the words of this service.

## Language

### Authentication

**Account**:

The Google account whose OAuth tokens a command uses. This is an **OAuth API**,
and its **Login** is `google-login`, shared with Google Docs. `--account`
selects the account, and the default account is used otherwise. The login asks
for the scopes `gmail.readonly` and `gmail.compose`. After a new scope, run
`google-login` again for each **Account**.

_Avoid_: profile, user

### Entities

**Message**:

A Gmail conversation: an array of **Mails**. The `id` that the commands print is
the id of the conversation. It has no **Anchor**, and has a **Fixed schema**.

_Avoid_: thread, conversation, email

**Mail**:

One exchange inside a **Message**, sent or received. A **Mail** is not an
**Entity** of its own, and no command lists it. A **Message** is read as a
whole: `read` prints all its **Mails**, and no command targets a single
**Mail**.

_Avoid_: message, email

`list-raw` prints the **Messages** of the inbox, as `▮` lines:
`messageId▮date▮count▮authors▮subject▮snippet▮unread`. `date` is the date of the
last **Mail**, `count` the number of **Mails**, and the authors are separated by
`▯`. Unread **Messages** come first, then the newest first.

**Attachment**:

A file carried by a **Mail**. It is not an **Entity** of its own: `read` lists
the attachments of each **Mail** (`partId`, `filename`, `mimeType`, `size`), and
`download` saves one of them. A part id is only unique inside its **Mail**, so
`download` takes the id of the **Mail**, not the id of the **Message**.

_Avoid_: file, document

**Draft**:

A **Mail** that is written and not sent, saved in Gmail. It has a **Fixed
schema** and no **Anchor**. A **Draft** is created as new, or as a reply to the
last **Mail** of a **Message**, in the same thread. A reply goes to all
recipients except the **Aliases**, and quotes the last **Mail**. No command
reads, changes, lists or sends a **Draft**: the user does it in Gmail, from the
`url` that `create` prints.

_Avoid_: unsent mail, reply

### Verbs

**`create`**:

The standard [`create`](/docs/api/reference/commands/create.md) verb of the
`draft` entity:
`gmail-draft-create --to <address> --subject <text> --body <text>` makes one
**Draft**, and prints `draftId`, `threadId` and `url` as JSON. `--body-file`
reads the body from a file, and sends a `.md` file as HTML too.
`--messageId <id>` replies to a **Message**. `--to` and `--subject` are then
optional, and override the reply.

_Avoid_: `add`, `new`, `write`, `reply`

**`download`**:

A **Custom verb** of the `attachment` entity:
`gmail-attachment-download mailId --partId <id>` saves one **Attachment** and
prints the path of the saved file. `--out` is an existing directory (the file
keeps its remote filename), a file path, or nothing (the current directory).

### Service terms

**Inbox**:

The Gmail label `INBOX`. The default list of **Messages** is the **Inbox**.

_Avoid_: mailbox, folder

**Alias**:

An address of an **Account** that can send **Mails**. The user lists them in an
environment variable: `OROSHI_GMAIL_ALIASES` for the default **Account**, and
`OROSHI_GMAIL_ALIASES_<ACCOUNT>` for `--account <account>`
(`OROSHI_GMAIL_ALIASES_PERSO` for `perso`). Both are comma-separated lists, and
a reply fails with `GMAIL_ALIASES_MISSING` when the list is empty. A reply to
all removes the **Aliases** from its recipients. It is sent from the **Alias**
that received the last **Mail**, or from the first **Alias** of the list when
none did.

_Avoid_: identity, sender, address

## Relationships

- A **Message** contains one or more **Mails**
- The **Inbox** holds zero or more **Messages**
- Every command uses the tokens of one **Account**
- An **Account** has one or more **Aliases**
- A **Draft** replies to the last **Mail** of one **Message**, or to none
- A reply **Draft** is sent from one **Alias** of the **Account**

## Flagged ambiguities

- "message" is the word of the Gmail API for one mail, and "thread" its word for
  a conversation — resolved: a **Message** is a conversation, and a **Mail** is
  one exchange. There is no `thread` entity. `--messageId` follows this rule: it
  takes the id of a **Message**, which Gmail calls a thread id.
