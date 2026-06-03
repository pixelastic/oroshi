In all interactions, and commit messages, be extremely concise and sacrifice
grammar for the sake of concision.

## Code

- DO: Use dedicated skill per language if they exist (`zsh-writer`, `js-writer`, etc)
- DO: Fetch up-to-date documentation (using Context7 MCP) before writing code
- DO: Prefer a DX that makes simple things easy and complex things possible
- DO: Apply the "return early" pattern in code
- DO: When editing code, preserve its comments. When deleting code, delete its comments with it.

- NEVER: Never suggest to write a script in python. Prefer zsh or JavaScript

## Throw-away scripts

- DO: Create your one-off scripts in a dedicated folder in /home/tim/local/tmp/claude
- DO: Use `jq` to read JSON, and `jo` to write JSON

- DON'T: Use `python` or `node` to inspect JSON. Use `jq` instead
