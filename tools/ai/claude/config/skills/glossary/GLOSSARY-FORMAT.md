# GLOSSARY.md

- **Be opinionated.** When multiple words exist for the same concept, pick the
best one and list the others under `_Avoid_`.
- **One sentence per term.** Define what the term IS. Do not describe what it
does or how it works.
- **Bold term names everywhere.** In definitions, relationships, ambiguities,
and decisions.
- **Every term has an `_Avoid_` list.** Even if empty, listing common bad
aliases prevents drift.
- **Domain-specific terms only.** General programming concepts (timeouts, error
types, retry logic) do not belong. Before adding a term, ask: is this concept
unique to this context, or a general programming concept? Only the former
belongs.
- **Cardinality in Relationships.** Express one-to-one, one-to-many,
zero-or-more explicitly.


---
## Template

```md
# {Module or Repo Name}

1-2 sentences describing what this context is and why it exists.

## Language

**Order**:
{A concise description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

```
---
