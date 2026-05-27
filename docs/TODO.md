json-lint errors when editing files outside of oroshi

git-file-lint should display a relative path from the repo root, not the full
path

claude-print, we might need to find a better way of handling the 0000-0000
session, I think there is an arg that can be passed that can do that

Still terminal issue when running several ralphs

See how to have yarn run test go through rtk as well

I will need to have vft and vfl work on js files (using yarn run test/yarn run
lint on them)

I should update my eslint rules to warn about using for of instead of lodash, so
the agents know when/how to write

I need to warn about "local desc="$([[ "$counters" != "" ]] && echo "${counters}
${message}" || echo "${message}")"" in zsh. The line is too long, I would rather
have that on several lines with a proper if


JS: I don't like   return getCommandLineState(commandLine, allowList).isAllowed;
I'd rather have a const { isAllowed } = getCommandLineState(aaa, bbb)
/home/tim/local/www/worktrees/solkan--rich-output/lib/isCommandLineAllowed.js

Add a CLAUDE.md at the root for aberlaas projects with aberlaas init, that
displays the commands to use (yarn run lint, yarn run test, etc)

Add completion of files modified to git-file-reverte on ctrlp

Pre-commit hook of editing js files should run the matching tests

Editing config/ai/claude/hooks/stop doesn't run the matching test when
committing, might need to check the shebang if +x more aggressively

Seems like bats output are not filtered through rtk? I think it's because rtk
doesn't know it can rewrite it, so the hook doesn't prepend rtk to it, even if
it should work. Should I configure rtk to know it can parse bats, or should I
replace each instance of caling bats with rtk bats?

I would like to have a visual indicator in my kitty tabs to tell me which tab
currently has a "job's done"

---

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

---

If I'm in a worktree of a cloned repo, but that repo is not part of my projects,
how should the badge be displayed? My initial assumpation was that project >
worktree > path, but in that case as there is no project, I think maybe the
worktree main name should be promoted to project?

I will need to rename the CONTEXT.md to GLOSSARY.md and have them co-located
with the code domain they represent. Maybe I'll need a GLOSSARY-MAP.md at the
repo root. Probably also a few DECISIONS.md to replace the ADR, to document
decisions. With a pattern of using `__docs` to store those infos. I also have a
`docs` folder at the root with temporary PRD/issues for each worktree. I wonder
if this is the right naming (docs? specs? agents?)

I need to find a way to add issues dynamically to an existing worktree/project.
Like I want to achieve A, but I see that folder something/ has dead code and
want to remember to clean it up.

I will need to rename /grill-with-docs to /glossary. It should also ask a lot of
question to get to a shared understanding, but define where/how to save the vocabulary.
I'm not sure if I should name it /glossary actually. I feel it's an important
part to document, but it might shadow the fact that it helps get to a common
understaning.

I'm having too many env variables for colors. Maybe a JSON file would be better,
and read in it when needed... Maybe add to the ENV variable after the first read

I will need to cleanup my scripts. Delete the ones I don't use anymore. Define
if it should be a script, a zsh autoloaded function, or a plain zsh helper
function. Group them in clear domains/subdomains, and make it consistent between
scripts and config (and install if needed).

I should also cleanup what is in private/, same pattern as what I do in core
oroshi
