## Issue 04 — vitals dashboard
### Return early pattern in display blocks
```zsh
printf "%-8s" "CPU"
if [[ "$cpuPercent" == "?" ]]; then
  echo "?"
else
  colorize "$(printf '%3s%%' "$cpuPercent")" "$cpuColor"
  echo
fi
```
**Problem:** Reviewer flagged six if/else blocks as violating the return-early pattern.
**Reason skipped:** Return-early applies to function guard clauses, not sequential display blocks where no `return`/`continue` is possible. The if/else is the natural structure for "if missing, show ?, otherwise show colored value."

### Magic number thresholds
```zsh
[[ $cpuPercent -ge 50 ]] && cpuColor="warning"
[[ $cpuPercent -gt 80 ]] && cpuColor="error"
```
**Problem:** Threshold values (50, 80, 60, etc.) are inline magic numbers, not UPPER_CASE constants.
**Reason skipped:** Each threshold is used once, in a clearly commented block. Named constants would add 12 declarations for no reuse benefit.

### Repeated display blocks
**Problem:** Six near-identical color-assignment and display blocks.
**Reason skipped:** Guidance says "avoid nested helper functions in autoload — they pollute caller's namespace." Each block has distinct field counts and formatting (RAM/Swap have used/total, Fans has avg, Temp has °C suffix). A loop would require more indirection than it saves.

### Temperature multi-sensor display
**Problem:** Spec shows CPU/GPU/NVMe temps but implementation shows only CPU.
**Reason skipped:** `sys-temperature` returns a single CPU temp value. Multi-sensor support would require changing the helper, which is out of scope for this issue.
