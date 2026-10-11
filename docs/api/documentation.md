# Documentation

How commands are documented.

## ZSH Wrapper

The comment lines at the top of the ZSH wrappers contain the documentation.

### Example

```zsh
# One-line description of the command
# (Optional details of what the command does)
# Usage:
# $ function-name arg        # What this does
# $ function-name arg --flag # With flag
```

- The one-line definition is what `helper-list` prints, to help the agent pick
  the right tool.
- `# Usage:` lists the accepted arguments, as one `$` example per line. It
  mirrors what the JavaScript module accepts. `helper-documentation` prints it.

The `# Usage:` header of every wrapper must list all the flags that the
JavaScript module accepts, and nothing else. Keep it in sync with the module.
The `create` and `update` templates show a `# Usage:` line for each schema mode
(fixed and open). The wrapper of an entity keeps only the lines of its own mode.
