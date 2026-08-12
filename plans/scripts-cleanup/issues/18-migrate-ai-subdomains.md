## Migrate ai/ subdomains to autoloaded

### deprecate/

- `deprecate-prepare`, `deprecate-end` → ai/deprecate/

### plan/

- `plan-start`, `plan-end` → ai/plan/
- `plan-directory`, `plan-progress` → ai/plan/ (move from ralph/)

### ralph/

- `ralph`, `ralph-end`, `ralph-start`, `ralph-state` → ai/ralph/
- `__lib/ralph-single.zsh`, `__lib/ralph-loop.zsh` → adapt path resolution

### review/

- `review`, `review-diff` → ai/review/

### sidequest/

- `sidequest-start`, `sidequest-end` → ai/sidequest/

### slack-writer/

- `slack-writer-start`, `slack-writer-tick` → ai/slack-writer/

### meetup-recap/ (added from main)

- `meetup-recap-start`, `meetup-recap-tick` → ai/meetup-recap/
