# Relationship between fix, lint, and lint --fix

`{lang}-fix` and `{lang}-lint` are independent scripts, each with a single
responsibility:

- **`{lang}-fix`** modifies files in-place (or stdout). Reports nothing.
- **`{lang}-lint`** reports violations. Modifies nothing.

Both can be called individually and must respect their contract in isolation.

**`{lang}-lint --fix`** is a shortcut for running both together: format in-place,
then report remaining violations. The end result is identical to
`{lang}-fix file && {lang}-lint file`.

The shortcut exists for two reasons:

1. **Performance** — some languages use the same underlying tool for fixing and
   linting (e.g. eslint with `--fix` does both in a single pass). Running them
   separately would launch the same tool twice.
2. **Code deduplication** — fix and lint often share boilerplate (config
   resolution, project root detection). A shared implementation
   avoids duplicating this logic.

The internal wiring varies by language. In some, `lint --fix` calls `fix` then
lints. In others, `fix` delegates to `lint --fix` internally. In others still,
both share a common core that handles either mode. The public API does not
prescribe the implementation — only the contracts above.
