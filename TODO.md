## Misc

json-lint errors when editing files outside of oroshi

When doing a sidequest, quitting claude ends the whole kitty window, while it
should fallback to zsh

Colors of markdown headers are off

Maybe I should remove the bats-lint custom rule aboutt using CURRENT if now the
best practice is to call the binary by name

Make sure no bats file contains a useless shebaang

Colors or scripts in fzf are off

Can't I remoove the teardown from all tests, as it always does the same thing,
can't I make it part of the helper once and for aaaall?

I should probably also migrate the filetypes definition like I did colors,
projects and icons.

If I'm in a worktree of a cloned repo, but that repo is not part of my projects,
how should the badge be displayed? My initial assumpation was that project >
worktree > path, but in that case as there is no project, I think maybe the
worktree main name should be promoted to project?

Closing a claude session in a directory that has been deleted (vwC) soft locks
the terminal
Still terminal issue when running several ralphs

I should update my eslint rules to warn about using for of instead of lodash, so
the agents know when/how to write

Check if we still need export OROSHI_ROOT_DEFAULT="$OROSHI_ROOT" and why

Double check we no longer use ZSH_CONFIG_PATH
nor OROSHI_ZSH_AUTOLOAD

Make a real htmlmin wrapper instead of the alias:
alias htmlmin="html-minifier --remove-comments --collapse-whitespace --remove-attribute-quotes --remove-redundant-attributes --use-short-doctype"


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

---
## fzf

fzf uses     as separator in many functions. Why? Why not use ▮ as all the other
functions do?
Overall I might need to have to ask an agent to look at the fzf diretcory and
all its functions and make sense of what it does, when it's called, etc, so we
can have a proper set of tests, and refactor it correctly. The commands are so
fragmented, it's becoming really hard to know what it does

Add completion of files modified to git-file-reverte on ctrlp


---

## Side projects

- MTG Scrensaver: A website that randomly pulls illustrations from Magic The
Gathering cards (using Scryfall API), and display them fullscreen. Fades to the
next at regular interval. Inspired by redditp.com. Maybe index all cards with
Algolia, so I can add filters (date, color, etc). Built using Lovable.
