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

### Issue 02 — ruby-dead-cleanup
- `tests/` was NOT deleted: `tests/data/` contains 14 MP3 fixture files. The spec assumed the dir would be empty after deleting the two test files, but the data fixtures live there too. The condition "if empty" was never met, so the directory was correctly kept.

### Issue 04 — img-legacy-cleanup
- HITL sign-off expanded scope: 7 scripts were migrated to ZSH before deletion (gifmin → bin script using gifsicle; jpgmin → wrapper like pngmin; png-mask, png2ico, tif2jpg, img-height, img-width → autoload functions).
- `review-diff` only shows tracked changes — untracked new files are invisible to it. The spec reviewer will falsely report migrations as missing. Ignore that false alarm.
- `png2ico` and `tif2jpg` peers (png2jpg, webp2png, etc.) don't have `setopt local_options err_return`, but the standard requires it — added to new files for correctness.
