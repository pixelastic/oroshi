## TLDR

Add file type validation to `bats-lint`: files that are not bats files produce a
`notBats` violation instead of being passed to shellcheck/custom.

## Context

Currently `bats-lint` passes all non-directory inputs directly to
`bats-lint-shellcheck` and `bats-lint-custom`. When an AI agent runs `bats-lint`
on a bats helper file or a zsh autoload function (e.g. `is-bats`) by mistake,
the sub-linters produce spurious violations and the agent starts trying to fix
them — making things worse. The `notBats` guard makes the linter fail fast with
a clear signal so the agent stops immediately instead of chasing false errors.

## What to build

Modify `scripts/bin/term/bats/bats-lint/bats-lint` to:

1. **Partition** `input[]` into two arrays after the directory-filter loop:
   - `valid[]` — files for which `is-bats "$file"` returns 0
   - `invalid[]` — all others

2. **Generate violations for invalid files** using `jq`:
   ```zsh
   local invalid_json='[]'
   if [[ ${#invalid[@]} -gt 0 ]]; then
     invalid_json="$(
       for file in "${invalid[@]}"; do
         jq -n --arg f "$file" \
           '{file:$f,code:"notBats",level:"error",line:1,endLine:1,column:1,endColumn:1,message:"Not a bats file"}'
       done | jq -cs '.'
     )"
   fi
   ```

3. **Run sub-linters only on valid files** — skip if `valid[]` is empty:
   ```zsh
   local valid_json='[]'
   if [[ ${#valid[@]} -gt 0 ]]; then
     valid_json="$(jq -cs 'add // []' \
       <(bats-lint-shellcheck "${valid[@]}") \
       <(bats-lint-custom "${valid[@]}"))"
   fi
   ```

4. **Merge and output**:
   ```zsh
   local merged="$(jq -cs 'add // []' <(printf '%s' "$invalid_json") <(printf '%s' "$valid_json"))"
   printf '%s\n' "$merged"
   [[ "$(printf '%s' "$merged" | jq 'length')" -gt 0 ]] && exit 1
   exit 0
   ```

Sub-linters (`bats-lint-shellcheck`, `bats-lint-custom`) remain unchanged — they
assume all files passed to them are valid bats files.

## Behavioral Tests

Add to `__tests__/bats-lint.bats` (mock `is-bats` with `bats_mock`,
mock sub-linters as in existing tests):

**Single invalid file:**
- `is-bats` returns 1 for the file
- `bats-lint-shellcheck` and `bats-lint-custom` are NOT called
- output is a JSON array with exactly one violation:
  `{code: "notBats", line: 1, column: 1, message: "Not a bats file"}`
- exit code is 1

**Mix — one valid + one invalid:**
- `is-bats` returns 0 for `valid.bats`, 1 for `other.zsh`
- `bats-lint-shellcheck` and `bats-lint-custom` are called with `valid.bats` only
- output merges the `notBats` violation with whatever the sub-linters return
- exit code reflects presence of violations

## Acceptance criteria

- [ ] `bats-lint some.zsh` outputs `[{..., "code":"notBats", ...}]` and exits 1
- [ ] `bats-lint valid.bats invalid.txt` merges both violation sets
- [ ] `bats-lint valid.bats` still works exactly as before (sub-linters called)
- [ ] new bats tests pass
- [ ] `bats-lint` on its own test files exits 0
