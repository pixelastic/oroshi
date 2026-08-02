# npm

Helpers for interacting with the npm registry — checking package status, authentication, and deprecation.

## Language

**Published**:
A package that exists on the npm registry and is installable via `npm install`.
_Avoid_: available, registered

**Deprecated**:
A published package whose registry metadata contains the `deprecated` flag. A sub-state of **Published** — a non-published package cannot be deprecated. A deprecated package remains installable.
_Avoid_: archived, retired

## Relationships

- A **Published** package can be zero or one times **Deprecated**
- A **Deprecated** package is always **Published**

## Flagged ambiguities

- "unpublished" (removed from registry via `npm unpublish`) is a distinct concept from "not published" (never existed). No helper covers this — out of scope for the current domain.
