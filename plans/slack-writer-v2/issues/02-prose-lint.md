## TLDR

Create a `prose-lint` script that wraps Vale and outputs a minimal JSON array of violations.

## What to build

A script at `scripts/bin/prose/prose-lint` that:

1. Accepts a file path as argument, OR text piped via stdin
2. If stdin, writes to a temp file and cleans up after
3. Calls Vale with `--config $OROSHI_ROOT/tools/prose/vale/vale.ini --output=JSON`
4. Reformats Vale's JSON output to a flat array: `[{line, rule, severity, match, message}]`
5. Exits 0 if no violations, 1 if violations found

The JSON reformatting strips Vale's Action, Description, Link, and Span fields to minimize token consumption when an agent reads the output.

## Behavioral Tests

**Clean text:**
- produces an empty JSON array
- exits with code 0

**Text with violations:**
- produces a JSON array with violations
- exits with code 1
- each violation has exactly 5 keys: line, rule, severity, match, message

**Stdin input:**
- produces the same output format as file input

## Acceptance criteria

- [ ] `prose-lint file.md` works with a file argument
- [ ] `echo "text" | prose-lint` works with stdin
- [ ] Output is a flat JSON array with only `{line, rule, severity, match, message}`
- [ ] Exit code 0 when clean, 1 when violations found
- [ ] All bats tests pass
