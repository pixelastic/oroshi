## Guidance

**Goal**: Remove dead code across four areas of the repo. No new code is written — this is pure deletion.

**Working directory**: `plans/deadcode/` (this file's location)

**Key rules**:
- Issues 01 and 02 are AFK: delete directly, no human confirmation needed.
- Issues 03 and 04 are HITL: always present a reference report to the user and wait for explicit sign-off before deleting anything.
- After any deletion, remove empty parent directories.
- `vimium-mappings.vim`, `html2pdf`, `gem-helper.rb`, and all `__pdf/` scripts are intentionally out of scope — do not touch them.

**Verification pattern for HITL issues**:
1. Enumerate all filenames/scriptnames inside the `__legacy/` folder.
2. Grep each name across: active scripts in the same `bin/` area + all ZSH autoload functions (`tools/term/zsh/config/functions/autoload/`).
3. Present results grouped by: "no references found" vs "referenced by: [list]".
4. Ask the user whether referencing scripts are themselves useful or dead.
5. Act only after explicit user decision.

**Linting/testing**: No tests to run. No lint needed (pure deletion).

## Discoveries

<!-- Append findings here after each issue, using: -->
<!-- ### Issue XX — short title -->
<!-- - finding -->
