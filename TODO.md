## Quick wins
- js-writer should have one named export per file, except for __

## Kitty
=> Keybinding to add status markers

## LUA
- Grill-me LUA
    => lua-lint, lua-fix, lua-test
        => Display context-badge pretty in nvim Ctrl-Shift-Y

---
Graph

aberlaas
    -> release still need high thinking to make it work
    -> will allow release aberlaas, so toml-lint will work


rss2lunii
    -> generating svg is buggy need a svg-fix
    -> svg-toolchain
        -> I don't want svgo as svg-fix, it will be svg-min
        -> I need a way to lint/format xml files
        -> xml-toolchain

git-file-watch
    -> side project, important so it unlocks upgrade of Claude
        -> which will unlock fix terminal corruption
            -> which will unlock ralph auto nightshift

---

- Add a lint rule to use `\{cmd}` instead of `command {cmd}` to bypass aliases
- Make some slack-* commands to read updated in a specific channel
- /debug-script skill doesn't work well with nodejs scripts that require a dependency. Need to see if it can use package.json for the deps?
- Make a better slack-writer skill, based on facts about effective writing, with some grill-me first and concise
- Add CLI tools to add items in my calendar
- Seem like we have both {language}-fix called by nvim and {language}-lint --fix
  called by agents and maybe lintstaged. Seems like a weird gap
- Prevent variables like `absArg` in code, prefer full words
- Find tests best practices, review my tests, see what goes wrong, update test
guidance, fix tests. Notably define when to do several tests, when to do one big
test. Also when to use real dependencies and when to mock them.
- vwR should close Claude sessions running in worktree. Currently seem to return
  early if one ralph is running. Is this good or bad?
- Ensure all linters use endLine/endColumn in their unified JSON output
- xml toolchain didn't add the completions
- Seems like the topbar reload script runs incrementally one more time each time
  I get out of suspend. Or at least, it fires several times.
- Add a zsh lint rule that flags short form arguments, with an allowlist of
authorized short forms
- See if we add a `{lang}-min` to compress files in the toolchain (useful for
svg, maybe for js as well)

---

## Kitty

- Ensure the right attention icon is displayed at the right time. Seems like I have the pause icon sometimes when Claude asks for something, while it should be a classical stop sign.
- No way to see which project/worktree I'm in in Kitty tabs
I'd love an icon to see:
- Claude is waiting for my input
- Claude is blocked by a permission to run something
- Claude has finished ralphing
- Claude is currently ralphing
- Would it be possible to send the mic2txt recording to the right Kitty panel if
  it was started from one, even if I alt-tab in between? kitty-remote send-text
  might be able to do that
- How to mark that a tab is blocked until a sidequest is resolved?
- Make a keybinding to automatically fix the text I have under my cursor
- Refactor prose-build; the code is ugly
- /plan creates a worktree, but doesn't move to it
- Make a better trash-restore, that uses fzf and preview to pick which file to restore
- Kitty keybinding to "mark" a tab with a specific icon (like re-adding an attention, or marking it as "to come back once other tab is done")
- evaluate if I need some allowed-tools/disallowed-tools in my skills
- Add a rule in zsh to prevent abbreviations like *Len, *Dir, abs*, proj*
- find a way to fill a brag doc (https://jvns.ca/blog/brag-documents/) regularly
- Add a script that can give me a daily recap of everything I accomplished on a
  given day. Initially by checking git history, later by checking GDrive
  activity and Slack
- Migrate rust dependencies (parakeet) at root level, just like package.json


---

## Skills

- Run claude on all history, analyzing common review issues, improve skills accordingly
- Ensure GUIDANCE uses the right test/lint commands, even outside of oroshi
- Ensure skill run `review-diff` from the path

---

## JavaScript

- Rule to enforce the try/catch pattern in tests
- Update aberlaas so it adds a CLAUDE.md to new projects, telling about the test/lint commands
- Disallow `method().property`, prefer `const { property } = method()`

---

## ZSH

- Ensure ``*-load-definition` are after the arg parsing
- `[[ "$allDone" == "true" ]] && { print '{"status":"done"}'; return 0; }` is invalid
- Refactor `compdef-glob-from-type.zsh` into its own __lib folder


---

## Nvim

- Always display a tab, even if only one, to easily see the file being edited
- Add lua-lint
- Add lua-lint --fix and lua-fix
- Add lua-test
- We need a lua test framework, specific to nvim
- Plug the lint/test into lintstaged
- Plug the lint/test into vfl and vft
- Plug the lint/test into nvim
- Add custom lint rules in lua to follow my standards (like using own methods rather than internals)
- Need a lua-writer skill
- Ctrl-Maj-Y should display the context-badge
- Shift-R in bats file generates an errors instead of adding a REVIEW: line
- Refactor nvim keybindings, they are all sprawling one big file
- Evaluate if F.run is strong enough. It seems to only work with a callback, maybe I need a sync version
- Add a F.removePrefix() that removes a given string from the beginning of another. Useful to get a relative path out of a known root
- Use icons.json instead of hardcoded icons
- Can't find anything with ctrl-g inside an ebook markdown
- zsh/fzf/nvim integration to open multiple files should use a temporary file with a script rather than inlining everything
- Refactor disk.lua, ensure a consistent pattern in the sinklist. Probably also need to extract fzf-related functions in their own file.
- Should reload a buffer when moving from one tab to another (only works when moving from one kitty window to another)
- Find which color is used to display the gutter when editing a file that has been deleted
- Refine the markdown header colors; they are off since I refactored the palette
- Delete COMMIT_HINT.md after use, so it doesn't get stale

---
## Cleanup

- Cleanup private/ scripts and autoloaded functions

---
## Ideas

- Update gamemaster/armory to renew the design, and to incorporate items from more games.
- Update blog.pixelastic.com. Find a blogging cadence, better UI
- Finish crsearch: search Critical Role video subtitles and jump to the exact moment something was said
