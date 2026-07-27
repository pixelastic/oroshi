## TLDR

Node.js CLI tool that removes a top-level key from a JSONC file while preserving comments.

## What to build

A Node.js script `jsonc-remove-key` in `tools/_languages/json/` that takes a file path and a key name, removes that key from the JSONC file, and writes the result back in place. Uses the `jsonc-parser` npm package (same library VS Code uses for settings.json).

Add `jsonc-parser` as a dependency in the root `package.json`.

The script should be callable as: `jsonc-remove-key <file> <key>`

If the key doesn't exist, exit silently with success (idempotent).
If the file doesn't exist or isn't valid JSONC, exit with error.

Follow the symlink pattern for bin scripts: symlink (no extension) pointing to the `.js` file.

## Behavioral Tests

**Happy path:**
- removes a top-level key from a JSONC file
- preserves `//` comments in surrounding entries
- preserves formatting/indentation of remaining entries
- writes result back to the same file

**Idempotency:**
- exits successfully when key doesn't exist in the file

**Error cases:**
- exits with error when file doesn't exist
- exits with error when file is not valid JSONC

## Acceptance criteria

- [ ] `jsonc-remove-key <file> <key>` removes the key and writes back in place
- [ ] Comments in the JSONC file are preserved
- [ ] Missing key is a no-op (exit 0)
- [ ] `jsonc-parser` added to root `package.json`
- [ ] Symlink pattern: `jsonc-remove-key` → `jsonc-remove-key.js`
- [ ] Tests pass
