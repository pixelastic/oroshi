## Issue 01 — noRunZsh rule

### Output format corrected post-issue: aligned with zshlint

Format updated from `file▮line▮col▮code▮message` to `file▮code▮error▮line▮message` to match zshlint exactly. The spec's `line▮col▮code▮message` was incorrect — zshlint-custom parses `fields[1..4]` and NeoVim expects that layout. All tests still pass.
