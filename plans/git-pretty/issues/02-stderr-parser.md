## TLDR

Pure Go module that parses git push stderr lines into structured events.

## What to build

A `parser` package that exposes a `ParseLine(line string) Event` function. Each event has a type and associated data:

- **progress** — phase name (e.g. "Compressing objects"), current count, total count, percentage. Parsed from lines like `Compressing objects:  81% (72/89)`
- **refUpdate** — from-ref, to-ref, branch, remote. Parsed from `abc1234..def5678  main -> main` and the `To github.com:...` line
- **remoteMessage** — raw text. Lines starting with `remote:` that aren't progress (e.g. GitHub PR URLs)
- **error** — raw text. Lines starting with `!`, `fatal:`, `error:`
- **upToDate** — no data. The line `Everything up-to-date`
- **noise** — everything else (Total, Delta compression, set up to track, etc.)

Handle `\r` (carriage return) splitting: git overwrites progress lines in-place using `\r`. The parser should handle lines split on both `\r` and `\n`.

## Behavioral Tests

**Progress parsing:**
- Parses percentage from "Counting objects: 100% (109/109), done."
- Parses in-progress percentage from "Compressing objects:  81% (72/89)"
- Parses writing objects with speed from "Writing objects: 100% (106/106), 18.40 KiB | 3.68 MiB/s, done."
- Extracts phase name correctly

**Ref update parsing:**
- Parses "To github.com:user/repo.git" as destination
- Parses "   825ed95..107ad51  main -> main" as ref update with branch names
- Parses forced update "  + abc1234...def5678 main -> main (forced update)"

**Remote message parsing:**
- Identifies "remote: Create a pull request..." as remote message
- Does not confuse "remote: Resolving deltas: 100%..." with a remote message (it's progress)

**Error parsing:**
- Identifies "! [rejected] main -> main (non-fast-forward)" as error
- Identifies "fatal: ..." as error

**Up to date:**
- Identifies "Everything up-to-date" as upToDate

**Noise filtering:**
- Identifies "Delta compression using up to 18 threads" as noise
- Identifies "Total 106 (delta 30), reused 0 (delta 0)" as noise
- Identifies "branch 'main' set up to track 'origin/main'." as noise

## Acceptance criteria

- [ ] `ParseLine` handles all git push stderr line types
- [ ] `\r` splitting works correctly
- [ ] All behavioral tests pass
- [ ] No side effects — pure function
