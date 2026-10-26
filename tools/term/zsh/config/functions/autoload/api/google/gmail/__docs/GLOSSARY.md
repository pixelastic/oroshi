# Gmail

The commands that let a shell or an agent read Gmail. It follows the
[API glossary](../../../../../../../../../../docs/api/GLOSSARY.md), and defines
only the words of this service.

## Language

### Authentication

**Account**:

The Google account whose OAuth tokens a command uses. This is an **OAuth API**,
and its **Login** is `google-login`, shared with Google Docs. `--account`
selects the account, and the default account is used otherwise.

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

### Service terms

**Inbox**:

The Gmail label `INBOX`. The default list of **Messages** is the **Inbox**.

_Avoid_: mailbox, folder

## Relationships

- A **Message** contains one or more **Mails**
- The **Inbox** holds zero or more **Messages**
- Every command uses the tokens of one **Account**

## Flagged ambiguities

- "message" is the word of the Gmail API for one mail, and "thread" its word for
  a conversation — resolved: a **Message** is a conversation, and a **Mail** is
  one exchange. There is no `thread` entity.
