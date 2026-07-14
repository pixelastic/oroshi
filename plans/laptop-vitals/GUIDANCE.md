## Guidance

- All functions go in `tools/term/zsh/config/functions/autoload/system/`
- Autoload convention: `setopt local_options err_return`, no shebang
- `--reply` flag pattern: `zparseopts -E -D -reply=flagReply`, check `[[ ${#flagReply} == "1" ]]` — see `tools/term/zsh/config/functions/autoload/misc/remove-ansi` for reference
- Field separator: `▮` (U+25AE) — codebase-wide convention
- hwmon discovery: iterate `/sys/class/hwmon/hwmon*/name`, match content string (`thinkpad`, `nvme`, `coretemp`) — never hardcode indices
- Thinkpad hwmon exposes `temp1_label=CPU`, `temp2_label=GPU`, `fan1_input`, `fan2_input`
- NVMe hwmon exposes `temp1_input`
- Colors: `colors-load-definitions` then use `$COLORS[error]`, `$COLORS[warning]`, etc.
- No tests — decision recorded in PRD
- Lint: `zsh-lint <filepath>` on every function written
- Use `local var="$(cmd)"` pattern for variable assignment (never split local/assignment)
- Use `[[ $flag == "1" ]]` for boolean tests, not `(( flag ))`

## Discoveries
