In all interactions, be extremely concise and sacrifice grammar for the sake of concision.

## Code

- DO: Prefer ZSH or JS for scripts; use Python only when there is no other choice.
- DO: Use `jq`/`jo` for JSON parsing in shell, never Python
- DO: Use dedicated skill per language if they exist (`zsh-writer`, `js-writer`, `python-writer`, etc)
- DO: Fetch up-to-date documentation (using Context7 MCP) before writing code
- DO: Prefer a DX that makes simple things easy and complex things possible
- DO: Apply the "return early" pattern in code
- DO: When editing code, preserve its comments. When deleting code, delete its comments with it.

## Clipboard

- DO: When writing mails, Slack messages, etc, copy it to the clipboard with `clipboard-write "text"`.
- DO: When asked to put something in the clipboard, use the `clipboard-write` command.
- DO NOT: use `xclip`, `xsel`, `pbcopy`, or `wl-copy` directly.

## Throw-away scripts

Use the `/debug-script` skill when writing complex or multi-step Bash commands.
