## TLDR

Create `sys-temperature`, `sys-fans`, `sys-battery` autoload functions in `system/`.

## What to build

Three autoload functions that read hardware sensor data.

**sys-temperature** — finds hwmon devices by matching `name` file (`thinkpad` for CPU/GPU, `nvme` for SSD). Returns `CPU▮GPU▮NVMe` as integer Celsius (e.g. `52▮48▮38`). Temps are in millidegrees in `/sys/`, divide by 1000. Thinkpad hwmon has labeled temps: `temp1_label=CPU`, `temp2_label=GPU`.

**sys-fans** — finds thinkpad hwmon by name match. Returns `avg▮fan1▮fan2` as integer RPM (e.g. `4039▮5293▮4786`). Average is arithmetic mean of fan1 and fan2.

**sys-battery** — reads from `upower -i $(upower -e | grep BAT)`, extracts percentage. Returns single integer (e.g. `87`).

All three support dual mode (`--reply` / echo) via `zparseopts`, same pattern as issue 02.

hwmon discovery: iterate `/sys/class/hwmon/hwmon*/name`, match content — never hardcode hwmon numbers (they change across reboots).

Graceful degradation: if a hwmon device isn't found (non-ThinkPad, missing NVMe), return `?` for that field instead of erroring.

## Acceptance criteria

- [ ] `sys-temperature` returns `CPU▮GPU▮NVMe` in integer Celsius
- [ ] hwmon devices discovered by name, not hardcoded index
- [ ] `sys-fans` returns `avg▮fan1▮fan2` in integer RPM
- [ ] `sys-battery` returns integer charge %
- [ ] All three support `--reply` flag
- [ ] Missing sensors return `?` instead of erroring
