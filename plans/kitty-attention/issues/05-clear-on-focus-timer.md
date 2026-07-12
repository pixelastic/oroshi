## TLDR

Automatically clear attention after the user stays on the focused tab for ~3 seconds.

## What to build

In `tabs_second_pass.py`, manage a single module-level `threading.Timer` (initially `None`). At `is_last=True`, after updating `activeTabId` and calling `cleanup`:

- **Active tab has attention** → cancel the existing timer (if any), create a new `threading.Timer(3.0, _on_attention_timer)`.
- **Active tab has no attention** → cancel the existing timer (if any), set it to `None`.

Only one timer is live at any time. Each render cycle that finds attention on the active tab resets the countdown to 3 seconds from now.

**Timer callback `_on_attention_timer`:**
- Read `tabState["activeTabId"]`.
- If that tab ID is still in `tabState["attentionIds"]`, remove its entry from the attention file and touch the redraw beacon.
- The callback only performs file I/O — no kitty Python API calls (thread-safety).

## Behavioral Tests

**Timer lifecycle**
- Timer is started when the active tab has attention
- Timer is cancelled and recreated on each subsequent render while attention persists (countdown resets)
- Timer is cancelled when the active tab no longer has attention
- Only one timer is live at a time

**Timer callback**
- Clears attention for the tab that is active at callback time (not necessarily the tab that was active when the timer was created)
- Does nothing if the active tab has no attention at callback time

## Acceptance criteria

- [ ] Staying on an attention tab for 3s clears its attention icon
- [ ] Cycling through tabs quickly (< 3s each) does not clear attention for passed-through tabs
- [ ] `test_tabs_second_pass.py` updated with timer tests
