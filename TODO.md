## SMALL

Add a zsh-lint rule that prevents long method call on one line, but suggest
splitting on several lines with \

yarn-dependency-list doesn't display anything

Also check the use of yarn-packager-colorize inside of pip-list. Probably not
useful.

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

compdef code triggers zsh-lint erorrs

Icons defined in nvim config are hardcoded and do not use our icons.zsh file.
Should we make them use it? How could they read it? Should they parse a JSON
version to get the icons?

I should probably also migrate the filetypes definition like I did colors,
projects and icons.

Seems like bats output are not filtered through rtk? I think it's because rtk
doesn't know it can rewrite it, so the hook doesn't prepend rtk to it, even if
it should work. Should I configure rtk to know it can parse bats, or should I
replace each instance of caling bats with rtk bats?

Add completion of files modified to git-file-reverte on ctrlp

I need to warn about "local desc="$([[ "$counters" != "" ]] && echo "${counters}
${message}" || echo "${message}")"" in zsh. The line is too long, I would rather
have that on several lines with a proper if

Editing config/ai/claude/hooks/stop doesn't run the matching test when
committing, might need to check the shebang if +x more aggressively

See how to have yarn run test go through rtk as well

Pre-commit hook of editing js files should run the matching tests

I will need to have vft and vfl work on js files (using yarn run test/yarn run
lint on them)

zshlint: [[ "$allDone" == "true" ]] && { print '{"status":"done"}'; return 0; }
Should be a real if [[ ]]; then fi

If I'm in a worktree of a cloned repo, but that repo is not part of my projects,
how should the badge be displayed? My initial assumpation was that project >
worktree > path, but in that case as there is no project, I think maybe the
worktree main name should be promoted to project?

Ctrl-Y in nvim should display the path using the context-badge like in statusbar

Doing a Ctrl-G to search in ebooks markdown files has a broken prompt, and badly
parses the selected files.

Closing a claude session in a directory that has been deleted (vwC) soft locks
the terminal

./scripts/etc seems to contain legacy code. See if needs removal.

My nvim keybidnings are sprawling over one big file. They probbaly need to be
split into smaller files, per domain.

---
## MEDIUM

json-lint errors when editing files outside of oroshi

Still terminal issue when running several ralphs

I will need to rewrite the way colors are loaded in zsh. They are in a huge env
file, I will need to update that to follow the same pattern as the projects
I'm having too many env variables for colors. Maybe a JSON file would be better,
and read in it when needed... Maybe add to the ENV variable after the first read

I will need to cleanup my scripts. Delete the ones I don't use anymore. Define
if it should be a script, a zsh autoloaded function, or a plain zsh helper
function. Group them in clear domains/subdomains, and make it consistent between
scripts and config (and install if needed).

I should also cleanup what is in private/, same pattern as what I do in core
oroshi

See if I can remove some submodules dependencies (for zsh highlight for example,
but not private/)

Reorg the tools/ in private/

---
## LARGE

I should update my eslint rules to warn about using for of instead of lodash, so
the agents know when/how to write

I would like to have a visual indicator in my kitty tabs to tell me which tab
currently has a "job's done"

fzf uses     as separator in many functions. Why? Why not use ▮ as all the other
functions do?
Overall I might need to have to ask an agent to look at the fzf diretcory and
all its functions and make sense of what it does, when it's called, etc, so we
can have a proper set of tests, and refactor it correctly. The commands are so
fragmented, it's becoming really hard to know what it does

I need to find a way to add issues dynamically to an existing worktree/project.
Like I want to achieve A, but I see that folder something/ has dead code and
want to remember to clean it up.

## glossary


I will need to rename /grill-with-docs to /glossary. It should also ask a lot of
question to get to a shared understanding, but define where/how to save the vocabulary.
I'm not sure if I should name it /glossary actually. I feel it's an important
part to document, but it might shadow the fact that it helps get to a common
understaning.

I will need to rename the CONTEXT.md to GLOSSARY.md and have them co-located
with the code domain they represent. Maybe I'll need a GLOSSARY-MAP.md at the
repo root. Probably also a few DECISIONS.md to replace the ADR, to document
decisions. With a pattern of using `__docs` to store those infos. I also have a
`docs` folder at the root with temporary PRD/issues for each worktree. I wonder
if this is the right naming (docs? specs? agents?)





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

I will need a test framework for LUA, and write tests, that I don't have yet.

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

---

## Side projects

- MTG Scrensaver: A website that randomly pulls illustrations from Magic The
Gathering cards (using Scryfall API), and display them fullscreen. Fades to the
next at regular interval. Inspired by redditp.com. Maybe index all cards with
Algolia, so I can add filters (date, color, etc). Built using Lovable.
