## Kitty

### Attention

When a new tab is opened, its id should be cleared from the attention list

Add a space after the icon

Make the icon after the fullscreen icon

See how to display a repo icon badge + the worktree name
Find a better separator icon between repo and wokrtree generally speaking?

Maybe we should remove the marker once we start typing, so I can easily clear
it?

the attention shouldn't be added when I run claude through git-commit-message
for example, only when actually interactive

When I quit claude, it should also clear the attention

### Redraw/reload

Diff betwen alt-R and alt-shift-r?

kitty-reload should write its beacon in its own subdir kitty/

kitty-reload shoudl be instand (beacon + -redrawn should trigger directly)

### Misc

See if we can mark it requires attention differently than an icon

I should expand to adding another "mode" icon, to show if the tab is in
grill-me, prd, issues, ralph or nothing

Can I add an icon in the tabs when claude is waiting for me to confirm a Bash
tool execution? Maybe I could keep the same icon (claude square) for each, but
change the color? Might not be readable in some context. Better to have a round
list of icons for the status.

Check if it would be possible to send the mic2txt transcript to the right window
even after I switch tabs, using kitty-remote send-text --match "id:$parentId"
that might be a way to have me switch between tabs even before the speech to
text is done, as soon as I'm done talking

Would be nice if we can find a way to name/color the kitty tabs based on their
main repo. I currently use a lot of worktrees, so if I name a tab "foo" in the
repo A, would be nice if the tab would be name "A foo" for example, or simply
using the repo A icon rather than A, and colored as this repo.



## Misc

Simplify the skill-writer skill, to remove the whole TDD part.
the skill-writer skill is too verbose. It has a TDD cycle that I don't actually
use. I should remove that and only keep the templates.

Make Claude inspect all the history of the review logs of deleted worktrees, and
classifying the most common skipped review, so I can improve my skills so they
are no longer suggested.

json-lint errors when editing files outside of oroshi

Move compdef-glob-from-type.zsh (or something like that) into its own `__lib`
folder, to follow with conventions

Check for each binary in scripts if they couldn't have been made as a zsh
autoloaded function. Define a clear glossary of why omething is a script raher
than a function. Find a way to write ina  comment in each script WHY something
is a script rather than a function. Find a plan to migrate them all from script
to function if needed

Colors of markdown headers are off in nvim

If I'm in a worktree of a cloned repo, but that repo is not part of my projects,
how should the badge be displayed? My initial assumpation was that project >
worktree > path, but in that case as there is no project, I think maybe the
worktree main name should be promoted to project?

Closing a claude session in a directory that has been deleted (vwC) soft locks
the terminal
Still terminal issue when running several ralphs

I should update my eslint rules to warn about using for of instead of lodash, so
the agents know when/how to write

Make git-worktree-distance use git-worktree-distance-raw

Update calls to bats_debug to not pass an argument, as $output is by default

Re-evaluate
/home/tim/local/www/worktrees/oroshi--vfa/tools/term/zsh/config/functions/autoload/git/branch/__tests__/git-branch-colorize.bats
to see if we could right better tests. Tests that actually test non-trivial
behavior. The --zsh flag thing basically test that the underlying colorize
method correctly handles --zsh. Let's re-evaluate if we need to test that at the git-branch-colorize level, or if it's ok to assume it's tested in the colorize method.

Refactor all the prompt/git.zsh funcctions so they eahc have thier own file
rather than all being in the same file


When I create a new worktree in a non-oroshi repo, it correctly create the
worktree, install yarn then displays a bunch of errors. I wonder if it doesn't
try to rloead the PATH/fpath from that worktree (it should not, as it's not an
oroshi worktree)

Make the zsh-lint rule of warning about long lines disabled for export
statements, I want to be able to export a very long API key without warnings.

git-commit-message should not be able to see my API keys. Maybe I should disable
the commit message generation when in the private submodule.

When I delete a file, but it was still open in nvim, the nvim gutter is
displayed in cyan. It means, there is a color definition for such a file
(opened, but deleted since). I need to find which it is, and map that to some
shade of red

Refactor
/home/tim/local/www/worktrees/oroshi--bats-refactor/tools/term/zsh/config/prompt/index.zsh
t extract each function into its own file. It will make further testing easier,
as each file can have its own test file.

js-writer: should suggest that each file exports one named function. Avoid
having files that export several functions. `__` would be an exception. Would
also need to actually analyze existing codebases to see if the part is generic
enough. I kinda see that's how I like it in the end, but sometimes I also like
to have helper files that contain many different functions. So maybe anything in
./helpers/ would be an exception?

zsh-rules: `local firstField="${lines[0]%%▮*}"` agents tend to write that. I
prefer using an intermediary split method. We should catch that in lint.

claude: statusbar doesn't correctly display the filepath when not in a git repo,
like in Dropbox for example. I probably need a Dropbox project though.


---
## Cleanup

I will need to cleanup my scripts. Delete the ones I don't use anymore. Define
if it should be a script, a zsh autoloaded function, or a plain zsh helper
function. Group them in clear domains/subdomains, and make it consistent between
scripts and config (and install if needed).

I should also cleanup what is in private/, same pattern as what I do in core
oroshi
Reorg the tools/ in private/

---
## zsh-lint

icons-load-definitions and other ``*-load-definition` should be after the arg
parsing. basically the header should look like:
```zsh
# Documentation, including Usage:
setopt local_options err_return

zparseopts -E -D \
  -link-local=flagLinkLocal
local isLinkLocal=${#flagLinkLocal}

icons-load-definitions

(...code...)
```

zshlint: [[ "$allDone" == "true" ]] && { print '{"status":"done"}'; return 0; }
Should be a real if [[ ]]; then fi


---
## Kitty

I would like to have a visual indicator in my kitty tabs to tell me which tab
currently has a "job's done"

---
## aberlaas

Add a CLAUDE.md at the root for aberlaas projects with aberlaas init, that
displays the commands to use (yarn run lint, yarn run test, etc)

JS: I don't like   return getCommandLineState(commandLine, allowList).isAllowed;
I'd rather have a const { isAllowed } = getCommandLineState(aaa, bbb)
/home/tim/local/www/worktrees/solkan--rich-output/lib/isCommandLineAllowed.js

---
## lua

I will need to add a LUA harness made of tests and lints.

Ctrl-Y in nvim should display the path using the context-badge like in statusbar

I will need a test framework for LUA, and write tests, that I don't have yet.

Seems like doing Shift-R in bats file generates an error instead of addinga
review?

My nvim keybidnings are sprawling over one big file. They probbaly need to be
split into smaller files, per domain.

I will also need  alinter. I currently have a LSP linter in nvim, but I will
need to have something as a CLI that I can run outside of nvim, and that gives
me the same results as in nvim. So i'll probably need to move to luacheck, and
ditch the LSP version. I will also need to add custom rules to teach the agent
how to code, like how to use my own methods.

I will need a lua-writer skill to package all of that, similar to the others.

Sometimes, TDD creates tests that are irrelevant. For example, it updated  a.lua
file, but wrote a bats file to ensure the file didn't contain a specific string.
The good solution would have ben to have a a lua test, but I'm not equipped for
that yet.

lua-writer should use F.run() rather than vim.fn.systemlist. Or actually, F.run
is asynchronous by default (it has onSuccess, onError). Maybe I would need a
better API for both sync and async? runSync maybe?

Add a F.removePrefix() that removes a given string from the beginning of
another. Useful to get a relative path out of a known root

Icons defined in nvim config are hardcoded and do not use our icons.zsh file.
Should we make them use it? How could they read it? Should they parse a JSON
version to get the icons?

Doing a Ctrl-G to search in ebooks markdown files has a broken prompt, and badly
parses the selected files.

Legacy script, to open multiple nvim tabs was writing the code in a file, and
load the file. I probably need to do the same, to avoid a too long list of args

Add a Ctrl-T alias to nvim? Or at least disable the tag error

Once all ctrl-* are migrated, I'll need to check disk.lua, to ensure a
consistent pattern for the sinklist
