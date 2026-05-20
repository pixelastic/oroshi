When creating a PRD, if I'm not in a worktree, the skill should create the
worktree and put the files there. I keep forgetting to create a WT before
starting grilling sessions, and only once I'm deep in the grill do I realize
it's gonna be big and require a dedicated worktree

I need to find a way to add issues dynamically to an existing worktree/project.
Like I want to achieve A, but I see that folder something/ has dead code and
want to remember to clean it up.

I will need a lua-writer skill, similar to zsh-writer and js-writer. It will
also need a dedicated linter to ensure coding standards automatically.

I will need to rename the CONTEXT.md to GLOSSARY.md and have them co-located
with the code domain they represent. Maybe I'll need a GLOSSARY-MAP.md at the
repo root. Probably also a few DECISIONS.md to replace the ADR, to document
decisions. With a pattern of using `__docs` to store those infos. I also have a
`docs` folder at the root with temporary PRD/issues for each worktree. I wonder
if this is the right naming (docs? specs? agents?)

I should update grill me (or CLAUDE.md?) to prevent Claude from wanting to jump
in implementation right away. More often than not, after a grilling session I
might want a PRD + Issues in a given worktree. I want it to ask me if I want a
PRD or implement right away and probably have it estimate if it could implement
right away (maybe if less than n lines or code, or only touch one file?)

I will need to cleanup my scripts. Delete the ones I don't use anymore. Define
if it should be a script, a zsh autoloaded function, or a plain zsh helper
function. Group them in clear domains/subdomains, and make it consistent between
scripts and config (and install if needed).

Is errexit in the autoloaded function a good idea? It's gonna do exit, while I
actually only want return, to quit the function, not kill the terminal.

I'd like to have .mp3 files and possibly less interesting dirs below in ctrl-p
fzf, to have the mosy import files first.

I still have a linter error in
/home/tim/.oroshi/scripts/bin/git/commit/git-commit-message/git-commit-message
in nvm because of the top shabag, while the local eslint should ignore it

## Bats

I will need a vft script that manually launches all the soon-to-be-comitted
tests, so I can see what the precommit will do

Prompt test files should better follow the naming of the file they test, so they
can get picked up.

I will need to cleanup the bats helper to have clear rules on how to write
tests, probably having extensive examples in the file to explain how to use it.
This should include guidance about temporary directories per test, how to mock
undelrying methods, how to test scripts and zsh functions, etc

I will need to update all existing tests to that standard and fix broken tests
