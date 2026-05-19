# skill-writer — Domain Glossary

## scope
The named unit of work for a specific skill improvement or bug fix. Identified by `--scope <id>`. A scope spans multiple `test` and `ask` operations, all oriented toward the same objective. Opened implicitly by `skill-writer test`, closed explicitly by `skill-writer clean`.

A scope is not a single run — it contains many runs. The name reflects the change being made (e.g. `fix-backticks`, `add-red-phase-guard`).

## subagent
The isolated claude instance launched by `skill-writer test` inside the worktree. **Fresh** means: no context inherited from the parent agent, no memory of previous test iterations. The subagent only knows what is explicitly passed in the prompt (and optionally the skill via `@filepath`).

`skill-writer ask` resumes the subagent from the most recent `test` run in the scope via `--continue`. It does not start a fresh subagent.

## worktree
The isolated git environment at `~/local/tmp/claude/skill-writer/<scope>/worktree/`. Created fresh on each `skill-writer test` call (previous worktree is cleaned first). Branch: `skill-writer/<scope>`.

## history
The stream-json file at `~/local/tmp/claude/skill-writer/<scope>/history.jsonl`. Created by `skill-writer test`, appended by `skill-writer ask`. Source of truth for what the subagent did and said within the scope.

## prompt
The text passed as the last positional argument to `skill-writer test` or `skill-writer ask`. In SKILL.md, referred to as "scenario" during RED/GREEN phases and "pressure context" during PRESSURE phase — but it is always a prompt at the CLI level.
