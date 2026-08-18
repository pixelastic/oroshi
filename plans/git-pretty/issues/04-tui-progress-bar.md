## TLDR

Bubbletea TUI model that renders a progress bar with phase name from parsed git events.

## What to build

A `tui` package with a bubbletea Model that:

- Receives parser events (progress type) via messages
- Renders a single line: `{phaseName}  {progressBar}  {percent}%`
- Uses the bubbles/progress component for the visual bar
- Updates in real-time as new progress events arrive
- Uses theme colors for the progress bar

The TUI at this stage is standalone — it can be tested by feeding it fake progress events. Wiring to the actual git process comes in issue 05.

## Acceptance criteria

- [ ] Bubbletea program starts and renders a progress bar
- [ ] Phase name updates as different phases arrive
- [ ] Progress bar fills based on percentage from parser events
- [ ] Colors come from the theme module
- [ ] Program can be quit with Ctrl+C
