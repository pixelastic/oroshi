## Context-badge

If I'm in a worktree of a cloned repo, but that repo is not part of my projects,
how should the badge be displayed? My initial assumpation was that project >
worktree > path, but in that case as there is no project, I think maybe the
worktree main name should be promoted to project?

## PRD

When creating a PRD, if I'm not in a worktree, the skill should create the
worktree and put the files there. I keep forgetting to create a WT before
starting grilling sessions, and only once I'm deep in the grill do I realize
it's gonna be big and require a dedicated worktree

I will need to rename the CONTEXT.md to GLOSSARY.md and have them co-located
with the code domain they represent. Maybe I'll need a GLOSSARY-MAP.md at the
repo root. Probably also a few DECISIONS.md to replace the ADR, to document
decisions. With a pattern of using `__docs` to store those infos. I also have a
`docs` folder at the root with temporary PRD/issues for each worktree. I wonder
if this is the right naming (docs? specs? agents?)

I need to find a way to add issues dynamically to an existing worktree/project.
Like I want to achieve A, but I see that folder something/ has dead code and
want to remember to clean it up.

I should update grill me (or CLAUDE.md?) to prevent Claude from wanting to jump
in implementation right away. More often than not, after a grilling session I
might want a PRD + Issues in a given worktree. I want it to ask me if I want a
PRD or implement right away and probably have it estimate if it could implement
right away (maybe if less than n lines or code, or only touch one file?)

I will need to rename /grill-with-docs to /glossary. It should also ask a lot of
question to get to a shared understanding, but define where/how to save the vocabulary.
I'm not sure if I should name it /glossary actually. I feel it's an important
part to document, but it might shadow the fact that it helps get to a common
understaning.

## Lua

I will need a lua-writer skill, similar to zsh-writer and js-writer. It will
also need a dedicated linter to ensure coding standards automatically.

## Colors

I'm having too many env variables for colors. Maybe a JSON file would be better,
and read in it when needed... Maybe add to the ENV variable after the first read

## Scripts

I will need to cleanup my scripts. Delete the ones I don't use anymore. Define
if it should be a script, a zsh autoloaded function, or a plain zsh helper
function. Group them in clear domains/subdomains, and make it consistent between
scripts and config (and install if needed).

## Zsh

I will need to add zshlint as a pre-commit hook for zsh scripts as well
