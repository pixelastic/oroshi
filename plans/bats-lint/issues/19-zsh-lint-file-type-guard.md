## TLDR

Add file type validation to `zsh-lint`: files that are not zsh files produce a
`notZsh` violation instead of being passed to shellcheck/custom.

## Context

Same problem as issue 18, applied to `zsh-lint`. When an AI agent runs
`zsh-lint` on a `.bats` file or another non-zsh file by mistake, the
sub-linters produce spurious violations and the agent starts trying to fix them.
The `notZsh` guard makes the linter fail fast with a clear signal so the agent
stops immediately instead of chasing false errors.

## What to build

Modify `scripts/bin/zsh/zsh-lint/zsh-lint` to:

1. **Partition** `input[]` into two arrays after the directory-filter loop:
   - `valid[]` — files for which `is-zsh "$file"` returns 0
   - `invalid[]` — all others

2. **Generate violations for invalid files** using `jq`:
   ```zsh
   local invalid_json='[]'
   if [[ ${#invalid[@]} -gt 0 ]]; then
     invalid_json="$(
       for file in "${invalid[@]}"; do
         jq -n --arg f "$file" \
           '{file:$f,code:"notZsh",level:"error",line:1,endLine:1,column:1,endColumn:1,message:"Not a zsh file"}'
       done | jq -cs '.'
     )"
   fi
   ```

3. **Run sub-linters only on valid files** — skip if `valid[]` is empty:
   ```zsh
   local valid_json='[]'
   if [[ ${#valid[@]} -gt 0 ]]; then
     valid_json="$(jq -cs 'add // []' \
       <(zsh-lint-shellcheck "${valid[@]}") \
       <(zsh-lint-custom "${valid[@]}"))"
   fi
   ```

4. **Merge and output**:
   ```zsh
   local merged="$(jq -cs 'add // []' <(printf '%s' "$invalid_json") <(printf '%s' "$valid_json"))"
   printf '%s\n' "$merged"
   [[ "$(printf '%s' "$merged" | jq 'length')" -gt 0 ]] && exit 1
   exit 0
   ```

Sub-linters (`zsh-lint-shellcheck`, `zsh-lint-custom`) remain unchanged — they
assume all files passed to them are valid zsh files.

## Behavioral Tests

Add to `__tests__/zsh-lint.bats` (mock `is-zsh` with `bats_mock`,
mock sub-linters as in existing tests):

**Single invalid file:**
- `is-zsh` returns 1 for the file
- `zsh-lint-shellcheck` and `zsh-lint-custom` are NOT called
- output is a JSON array with exactly one violation:
  `{code: "notZsh", line: 1, column: 1, message: "Not a zsh file"}`
- exit code is 1

**Mix — one valid + one invalid:**
- `is-zsh` returns 0 for `valid.zsh`, 1 for `other.bats`
- `zsh-lint-shellcheck` and `zsh-lint-custom` are called with `valid.zsh` only
- output merges the `notZsh` violation with whatever the sub-linters return
- exit code reflects presence of violations

## Acceptance criteria

- [ ] `zsh-lint some.bats` outputs `[{..., "code":"notZsh", ...}]` and exits 1
- [ ] `zsh-lint valid.zsh invalid.txt` merges both violation sets
- [ ] `zsh-lint valid.zsh` still works exactly as before (sub-linters called)
- [ ] new bats tests pass
- [ ] `zsh-lint` on its own test files exits 0
