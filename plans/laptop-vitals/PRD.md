## Problem Statement

The user's ThinkPad hard-crashed from a thermal/GPU lockup during video playback on a hot day. There was no software cause — purely thermal. There is currently no way to get a quick overview of system vitals (temps, fans, CPU, memory, battery) to spot danger before a lockup occurs.

## Solution

A `vitals` autoload function that prints a compact, color-coded dashboard of system health. Behind it, a set of `sys-*` helper functions each read one data point from `/sys/class/hwmon/`, `/proc/`, or `upower`, returning structured data via `REPLY` or echo. The helpers are independently callable for scripting or statusbar use.

## User Stories

1. As a ThinkPad user, I want to run `vitals` and see all system health metrics at a glance, so that I can spot thermal danger before a lockup
2. As a user, I want CPU/GPU/NVMe temperatures color-coded by severity, so that I can immediately see what's hot
3. As a user, I want to see fan RPMs so that I can tell if fans are spinning up or failing
4. As a user, I want to see CPU usage percentage, so that I can correlate load with temperature
5. As a user, I want to see RAM and swap usage with both percentage and absolute values, so that I can spot memory pressure
6. As a user, I want to see battery charge percentage, so that I know remaining power at a glance
7. As a user, I want to run `sys-temperature` standalone and get raw values, so that I can use it in scripts or statusbar
8. As a user, I want `sys-cpu --reply` to set REPLY without printing, so that `vitals` can collect data without subshell overhead
9. As a user, I want hwmon devices discovered by name (not hardcoded numbers), so that the script survives reboots where hwmon indices change
10. As a user, I want all output on a single screenful, so that I don't need to scroll
11. As a user, I want green/yellow/red coloring based on thresholds, so that normal values don't distract from concerning ones
12. As a user, I want `amd-or-arm`, `gnome-shell-version`, and `ubuntu-version` available as autoload functions in the same `system/` directory, so that system info utilities are colocated

## Implementation Decisions

- All functions live in `tools/term/zsh/config/functions/autoload/system/`
- `sysinfo/` scripts (`amd-or-arm`, `arm-or-amd` symlink, `gnome-shell-version`, `ubuntu-version`) are migrated to `system/` as autoload functions (shebang + `set -e` replaced with `setopt local_options err_return`)
- Six `sys-*` helpers, each returning structured data:
  - `sys-cpu` returns usage % (single integer)
  - `sys-ram` returns `%▮current▮max` (e.g. `34▮8.2G▮30G`)
  - `sys-swap` returns `%▮current▮max`
  - `sys-temperature` returns `CPU▮GPU▮NVMe` (integer Celsius)
  - `sys-fans` returns `avg▮fan1▮fan2` (integer RPM)
  - `sys-battery` returns charge % (single integer)
- All `sys-*` helpers support dual mode: echo by default, `--reply` sets REPLY silently (same pattern as `remove-ansi`)
- `--reply` flag parsed via `zparseopts -E -D -reply=flagReply`
- `▮` (U+25AE) used as field separator, consistent with the rest of the codebase
- hwmon devices discovered by iterating `/sys/class/hwmon/hwmon*/name` and matching on `thinkpad`, `nvme`, `coretemp` — never hardcoded hwmon numbers
- CPU usage read from `/proc/stat`
- RAM/swap read from `free`
- Battery read from `upower`
- `vitals` calls each `sys-*` with `--reply`, formats output as aligned columns with `°C` suffix on temps and `RPM`-like context on fans
- Color thresholds using `colors-load-definitions`:
  - CPU: green <50%, yellow 50-80%, red >80%
  - RAM: green <60%, yellow 60-85%, red >85%
  - Swap: green 0%, yellow 1-50%, red >50%
  - Temperature: green <60°C, yellow 60-80°C, red >80°C
  - Fans: green <3000, yellow 3000-5000, red >5000
  - Battery: green >30%, yellow 10-30%, red <10%
- Zero external dependencies — no `sensors` or `smartctl` needed

## Testing Decisions

No tests for now. The `sys-*` helpers are thin wrappers around `/sys/` and `/proc/` file reads — mocking filesystem paths would be more infrastructure than value. Tests can be added later if formatting logic in `vitals` grows complex.

## Out of Scope

- GPU usage monitoring (no i915 usage metric exposed without `intel_gpu_top`)
- Disk SMART health (requires `smartctl` + root)
- Historical data / logging / trending
- Watch/refresh mode (user can use `watch vitals` if needed)
- Statusbar JSON output (existing `statusbar-cpu`/`statusbar-ram` already cover that)
- CPU frequency display

## Further Notes

- The `thinkpad` hwmon exposes labeled temps for both CPU and GPU (`temp1_label=CPU`, `temp2_label=GPU`), plus two fan inputs — this is the primary data source for thermals and fans
- The `nvme` hwmon provides SSD temperature
- If run on a non-ThinkPad or a machine without expected hwmon devices, helpers should return empty/zero gracefully rather than erroring
