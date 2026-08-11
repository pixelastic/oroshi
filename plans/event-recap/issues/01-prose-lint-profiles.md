## TLDR

Create `meetup-recap` and `slack-writer` prose-lint profiles that inherit from default.

## What to build

Add two new Vale profile source files:
- `tools/prose/vale/src/meetup-recap.ini` — empty overrides, inherits default
- `tools/prose/vale/src/slack-writer.ini` — empty overrides, inherits default

Run `prose-build` to generate the corresponding `dist/` files.

Verify that `prose-lint --profile meetup-recap` and `prose-lint --profile slack-writer` work and produce the same results as the default profile.

## Behavioral Tests

- `prose-lint --profile meetup-recap "I will utilize this"` returns an error (inherited from default)
- `prose-lint --profile slack-writer "I will utilize this"` returns an error (inherited from default)
- `prose-lint --profile meetup-recap "This is fine"` returns zero violations
- `prose-lint --profile slack-writer "This is fine"` returns zero violations

## Acceptance criteria

- [ ] `tools/prose/vale/src/meetup-recap.ini` exists
- [ ] `tools/prose/vale/src/slack-writer.ini` exists
- [ ] `prose-build` runs without error
- [ ] `tools/prose/vale/dist/meetup-recap.ini` generated, identical to `dist/default.ini`
- [ ] `tools/prose/vale/dist/slack-writer.ini` generated, identical to `dist/default.ini`
- [ ] `prose-lint --profile meetup-recap` works end-to-end
- [ ] `prose-lint --profile slack-writer` works end-to-end
