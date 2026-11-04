# Pages

A **Page** is an entity made of a text, that a user edits piece by piece. A
Google Doc, a Notion page and a Confluence page are all Pages. Their services
differ, but their commands share one vocabulary, written here once.

This file is also the glossary of the Page domain.

## Vocabulary

**Page**:

An entity of a service that holds a structured text: a Google Doc, a Notion page
or a Confluence page. The text is read and written as Markdown.

**Passage**:

A part of the text of a Page, written as Markdown.

_Avoid_: snippet, excerpt, selection

## Fields

A Page has a title and a body. The title is required, and cannot be empty. The
body is optional: `create` can make an empty Page, and `update` can empty the
body.

## Commands

A Page follows the [base verbs](../commands/README.md), and adds three custom
verbs to change its text by pieces:

| Verb                             | Role                                       |
| -------------------------------- | ------------------------------------------ |
| [`append`](commands/append.md)   | Add content at the end of the Page         |
| [`replace`](commands/replace.md) | Replace one Passage of the Page by another |
| [`remove`](commands/remove.md)   | Delete one Passage of the Page             |
