# Documentation and code examples

I want to have working code examples and up-to-date information

- **ALWAYS use Context7 MCP FIRST** when dealing with code examples, setup, configuration and library/API documentation

# Coding Style

Keep a consistent coding style matching my preferences across my projects

- Don't suggest scripts in python. Prefer scripts in zsh or in JavaScript
- Prefer camelCase for variables, functions, directories, files, etc (unless that specific language/project has a strong opinion against it)
- Prefer to "return early" in functions if conditions are not met, rather than putting most of the code in a condition
- Prefer a DX that makes simple things easy and complex things possible

# Shell Commands

My shell environment has custom aliases that override standard commands, but you run in a clean bash environment that doesn't inherit these aliases.

## For simple operations: Use built-in tools (NOT bash)

- **Use Glob tool** instead of `find` or `fd` for finding files
- **Use Grep tool** instead of `grep` or `rg` for searching in files
- **Use Read tool** instead of `cat` or `bat` for reading files

These tools are optimized, have better output formatting, automatic pagination, and avoid spawning unnecessary shell processes.

## For complex bash pipelines: Use real commands (NOT standard Unix names)

When you genuinely need bash (complex pipelines, chaining commands, advanced scripting), use these modern alternatives:

- **Use `fd`** (NOT `find`) - Modern file finder at `/usr/bin/fd`
  - Example: `fd -e zsh -x du -h | sort -h`
- **Use `rg`** (NOT `grep`) - Ripgrep at `/usr/bin/rg`
  - Example: `rg -c "pattern" | sort -t: -k2 -n`
- **Use `exa`** (NOT `ls`) - Modern ls at `/home/tim/local/bin/exa`
  - Example: `exa -la --sort=modified`
- **Use `trash`** (NOT `rm`) - Safe deletion at `/usr/bin/trash-put`
  - Or use `/bin/rm` if you need the real rm
  - Example: `trash old-file.txt`
- **Use `/usr/bin/cat`** (NOT `cat`) - Real cat command
  - Example: `/usr/bin/cat file.txt | grep pattern`

Why not standard names? My interactive shell has aliases (find→fd, grep→rg, ls→exa, rm→trash) but your bash environment doesn't inherit these. Using standard names will call the old Unix tools, not my preferred modern alternatives.

# Dependencies

If you need to check how some dependencies are working, you can find there on
disk:
- aberlaas: /home/tim/local/www/projects/aberlaas
- firost: /home/tim/local/www/projects/firost

# Debug

If you need to create scripts for debugging:
- Create them in /home/tim/local/tmp/claude
- Create one subdirectory per conversation
