## Problem Statement

During debugging and exploration sessions, Claude gets into Bash loops — running 5 to 10 complex commands in a row, each requiring manual user approval. This interrupts flow and forces the user to review commands that are inherently ephemeral and low-risk. The root cause is twofold: Claude defaults to inline Bash for all commands regardless of complexity, and the existing documentation tells it *where* to write scripts but not *when* or *how*.

## Solution

Introduce a `debug-script` skill that encodes the full throw-away script pattern, and update `~/CLAUDE.md` to point to it whenever Claude anticipates running syntactically complex Bash commands. Update the hook allowlist to auto-approve any script executed from the dedicated scripts folder.

## User Stories

1. As a user, I want Claude to automatically reach for a script file when composing a multi-line or complex Bash command, so that I don't have to tell it to do so manually.
2. As a user, I want Claude to know the exact file naming convention (no extension, shebang, chmod+x), so that the script executes correctly in the zsh autoload environment.
3. As a user, I want Claude to know where to save throw-away scripts (`/tmp/oroshi/claude/scripts/`), so that they are isolated from the project and easy to find.
4. As a user, I want scripts in the dedicated folder to be auto-approved by the hook, so that the whole point of the pattern — fewer interruptions — is actually achieved.
5. As a user, I want the same pattern to apply whether Claude is writing zsh or Node.js debug code, so that I don't need separate mental models.
6. As a user, I want `~/CLAUDE.md` to stay lean and point to a skill for details, so that the pattern is easy to update without touching global config.
7. As a user, I want Claude to understand that simple allowlisted commands (git, grep, ls) don't trigger the script pattern, so that it doesn't over-apply it and bypass the allowlist system unnecessarily.

## Implementation Decisions

- **Trigger condition:** Claude should use the `debug-script` skill when it anticipates writing a Bash command that is syntactically complex — multi-line, uses subshells, or involves non-trivial pipes. Simple read-only commands that chain normally (e.g. `git status && git diff`) do not qualify.
- **`~/CLAUDE.md` change:** The content of the existing `## Throw-away scripts` section is replaced by a single directive: use the `debug-script` skill for complex Bash commands. The section heading and folder reference are preserved for context.
- **New `debug-script` skill:** A new skill is created in the oroshi skills directory. It documents: the trigger condition, the target folder, the file naming convention (no extension), the shebang line, the chmod+x step, direct execution, a concrete zsh example, and the node variant (identical pattern, different shebang).
- **Allowlist glob entry:** The hook allowlist receives a new glob entry matching any script path under the dedicated folder. This uses the glob support recently added to solkan (`/**` suffix). The entry is added at the top of the allowlist file for visibility.
- **No skill for `zsh-writer`:** The debug-script pattern is a debugging concern, not an implementation concern. It is not added to `zsh-writer` or `js-writer`.

## Testing Decisions

No automated tests are written for this PRD. All three deliverables are configuration or documentation artifacts:
- `allowlist.json` is a config file — it is the artifact, not code under test.
- `~/CLAUDE.md` is a documentation file.
- The `debug-script` skill is a markdown file.

Per project convention, config file changes are not verified by bats or vitest tests.

## Out of Scope

- Git-specific glob patterns in solkan.
- Changes to the `zsh-writer` or `js-writer` skills.
- Changes to `~/.oroshi/CLAUDE.md` (project-level config) — the global `~/CLAUDE.md` is sufficient.
- Automated cleanup of scripts in `/tmp/oroshi/claude/scripts/`.
- Any changes to the solkan project itself (glob support was implemented as a prerequisite in a separate sidequest).
