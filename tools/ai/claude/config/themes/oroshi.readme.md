# Claude Code colors

Claude Code colors come from two places: the UI theme (`/theme`), and the syntax
highlighting (internal)

## UI theme

We have `theme` defined to `custom:oroshi`, itself extending `dark`. The
definition is `./src/oroshi.json` which gets translated to `./dist/oroshi.json`
through `./generate-theme`.

## Syntax highlighting

Claude has no settings to change syntax highlighting; it's hardcoded in its
binary. But we have `../patch/syntax/generate-syntax` that patches the binary in
place. It's fragile, can break on any update, but so far it's working.

`../patch/syntax/src/claude-syntax.jsonc` maps each highlight.js scope used by
Claude Code, and the diff line number and marker colors, to a color name from
`colors.jsonc`, like the bat theme does. So changing a color name (e.g.
`keyword`) updates Claude along with the other tools.

### How the patch works

The binary is a Bun standalone executable, embedding the source and the
precompiled bytecode of each module.

1. Each table is replaced in place by one of the exact same length (padded with
   spaces), so no offset in the binary moves
2. The bytecode of the patched modules is removed, so Bun compiles them from
   the patched source instead of running the original bytecode
3. The result is written to a temporary file then renamed over the binary: it
   can't be written while Claude is running, and yarn hardlinks it to its
   global cache

It is re-run by `colors-reload`, when saving the patch source in Neovim, and
when committing it. It must be run manually after each Claude
Code update, as `yarn install` restores the original binary. It fails if the
patched code can't be found, which likely means a Claude Code update changed
it.
