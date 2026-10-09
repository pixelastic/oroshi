# `format<Entity>`

`format<Entity>` turns one entity, as returned by the API, into the entity that
a command prints.

## Role

- `format<Entity>` is the one place that defines what a command prints for an
  entity.
- Each entity owns one, in `<service>/__lib/<entity>/format<Entity>.js`
  (`formatPage.js`, `formatRecord.js`).
- By default, it returns the raw object of the API, so agents can easily
  understand what it represents.
- It may tidy the object, to make it easier for other commands to consume.
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
  // Keep the shape of the API, and only tidy what makes it easier to read
  return response;
}
```

The test covers the function only. It checks that a given API response gives the
expected entity.
