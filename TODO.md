## UNSORTED

- Validate display of context-badge if in a worktree of a repo that is not a project (cloned). What should be displaye?
- Closing a claude session in a removed (vwR) directory still sometimes use 100% CPU
- Work on having ralph iterate on several issues in a row
- Make git-worktree-distance use git-worktree-distance-raw
- vws shouldn't suggest "main" when not in a git repo
- Update calls to bats_debug to not pass an argument, as $output is by default
- Review git-branch-colorize tests. They seem trivial and useless
- Refactor the prompt/git.zsh functions into their own files
- Ensure zsh-lint doesn't yell about exporting a long API KEY
- git-commit-message should be retsricted in private/, to not see API keys
- js-writer should have one named export per file, except for __
- `local firstField="${lines[0]%%▮*}"` is bad, use a split array
- json-lint doesn't work on files outside of oroshi

---

## Kitty

- Ensure the right attention icon is displayed at the right time. Seems like I have the pause icon sometimes when Claude asks for something, while it should be
a classical stop sign.
- No way to see which project/worktree I'm in in Kitty tabs
- Change the attention icon in orange, for claude
I'd love an icon to see:
- Claude is waiting for my input
- Claude is blocked by a permission to run something
- Claude has finished ralphing
- Claude is currently ralphing
- Would it be possible to send the mic2txt recording to the right Kitty panel if
  it was started from one, even if I alt-tab in between? kitty-remote send-text
  might be able to do that
- How to mark that a tab is blocked until a sidequest is resolved?


---

## Skills

- Run claude on all history, analyzing common review issues, improve skills accordingly
- Merge /prd and /issues into /plan
- Check if I can define specific models per skill
- Ensure if writes the PRD file without asking for confirmation
- Ensure GUIDANCE uses the right test/lint commands, even outside of oroshi
- Ensure /prd calls prd-end from its path, not `bash /path/prd`, not `.claude/prd`, etc

---

## JavaScript

- Rule to enforce the try/catch pattern in tests
- Rule to prefer mockReturnValue over mockResultValue
- Update aberlaas so it adds a CLAUDE.md to new projects, telling about the test/lint commands
- Disallow `method().property`, prefer `const { property } = method()`
- Rule (or agent?) to not add comment doc on proxy in __
- Cleanup the new ESLint rules. Make an aberlaas official plugin maybe, see how
  to split them between js and vitest?

---

## ZSH

- Ensure ``*-load-definition` are after the arg parsing
- `[[ "$allDone" == "true" ]] && { print '{"status":"done"}'; return 0; }` is invalid

Move compdef-glob-from-type.zsh (or something like that) into its own `__lib`
folder, to follow with conventions


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

---
## Cleanup

- Cleanup scripts and autoloaded functions. Delete the unused ones.
- Define what should be a script and what should be an autoloaded
- Migrate everything that should be a function and not a script to a functions
- Cleanup private/ scripts and autoloaded functions
- Reorg by domain and install/deploy in private/
