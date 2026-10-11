# `format<Entity>`

`format<Entity>` turns one entity, as returned by the API, into the entity that
a command prints.

## Role

- `format<Entity>` is the one place that defines what a command prints for an
  entity.
- Each entity owns one, in `<service>/__lib/<entity>/format<Entity>.js`
  (`formatPage.js`, `formatRecord.js`).
- By default, it's an identity pass-through (it returns the same object it got
as input).
- It tidies the object only when a real response shows that a command
  needs it, to make the object easier for other commands to consume.
- Having one central function ensures all commands deal with the same shape of
  data.
- Other modules call it through `__` (`__.formatEntity()`), so tests mock it.

## Inputs/Outputs

- Input: one entity, as returned by the API.
- Output: the formatted entity, as close as possible to the API.

## Template

`<service>/__lib/<entity>/format<Entity>.js`:

```javascript
/**
 * Format one entity of the API, to give every command the same output
 * @param {object} response - The entity, as returned by the API
 * @returns {object} The entity, as close as possible to the API
 */
export function formatEntity(response) {
  // Identity by default. Tidy only what a real response shows is needed
  return response;
}
```

The test covers the function only. It checks that a given API response gives the
expected entity.
