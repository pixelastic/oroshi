# CLAUDE.md

The way I work is different from how other people use Claude Code. I have
preferences, aliases and common patterns I want Claude Code to be using.

## Main rules

**DO**:
- Fetch up-to-date documentation before writing code using Context7 MCP
- Create your scripts in a dedicated folder in /home/tim/local/tmp/claude
- Prefer a DX that makes simple things easy and complex things possible
- Apply the "return early" pattern in code
- Use dedicated skill per language if they exist (`zsh-writer`, `js-writer`, etc)

**DON'T**:
- Never suggest to write a script in python. Prefer zsh or JavaScript
- Never use directly `ls`, `cat` or `grep`. Use either `/usr/bin/ls` or my favored alternative like `exa`.

### Up-to-date documentation

I want to have working code examples, not outdated or hallucinated APIs.

- Always use Context7 MCP first when dealing with code examples, setup, configuration or library/API documentation

### Temporary script

If you need to write a script for processing or debugging, write it in
/home/tim/local/tmp/claude, with a specific subfolder per conversation

### Coding style

I like clear and concise code, that makes the happy path obvious, but allow for
configuration if needed.

- Prefer a DX that makes simple things easy and complex things possible
- Prefer a "return early" style of coding, rather than having nested if/else
- I hate python, do not suggest to write scripts in python
- I have dedicated skills per language that you should load when writing in `zsh` or `js`

### Aliases

I have aliased common CLI tools to better versions (`ls` => `exa`, `grep` => `rg`, etc).

When using those tools in complex commands, make sure you either:
- Use the better alternative (`fd` in place of `find`, etc)
- Use the real version with its full page (`/usr/bin/ls` instead of `ls`);

Aliases commands:
- `cat` => `bat`
- `find` => `fd`
- `grep` => `rg`
- `ls` => `exa`
- `rm` => `trash`
