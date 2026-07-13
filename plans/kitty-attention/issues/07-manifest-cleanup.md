## TLDR

Prune stale manifest entries for closed tabs after the display pass.

## What to build

When a tab is closed, its entry in `tabState["manifest"]` is never removed. Over time this accumulates stale metadata for tabs that no longer exist.

After the display pass completes (end of `second_pass`), remove any manifest key whose tab ID is not in `tabState["allTabIds"]`. This syncs the manifest with the actual set of open tabs.

## Behavioral Tests

**tabs_second_pass (on last tab)**
- Manifest entries for tab IDs not in `allTabIds` are removed after second pass
- Manifest entries for tab IDs in `allTabIds` are preserved

## Acceptance criteria

- [ ] Stale manifest entries are pruned at the end of each render cycle
- [ ] Active tab data is not affected
- [ ] Python tests written and passing
