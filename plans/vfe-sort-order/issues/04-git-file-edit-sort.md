## TLDR

Add source-before-test sort logic to `git-file-edit` using `test-path`.

## What to build

Modify `git-file-edit` to reorder `fileList` so each source file is immediately followed by its test file (if the test is also in the dirty list).

Algorithm (two-list + consumed):

1. Build `fileList` as today (filter by status, existence, plan artifacts, filetypes)
2. Create empty `sortedList` array and empty `consumed` associative array
3. Iterate `fileList`: if file is in `consumed`, skip it
4. Add file to `sortedList`
5. Call `test-path "$file"` — if it returns a path that exists in `fileList` and is not consumed, append it to `sortedList` and mark it as consumed
6. Open `nvim -p $sortedList` instead of `nvim -p $fileList`

Edge cases:
- Test-only dirty (no source modified): test stays at its natural position, never consumed
- Source-only dirty (no test modified): test-path returns nothing or returns a path not in the list, source appears alone
- Multiple source+test pairs: each pair is adjacent

## Behavioral Tests

**Source and test both dirty:**
- source appears before test in the output list

**Multiple pairs dirty:**
- each source is immediately followed by its test

**Only test file dirty:**
- test file appears in the list (not dropped)

**Only source file dirty:**
- source file appears in the list, no gap or error

**No test relationship (e.g. config file):**
- file appears at its natural position

**Mixed: some paired, some unpaired:**
- paired files are adjacent (source then test), unpaired files at their natural position

## Acceptance criteria

- [ ] Source files appear before their test files in nvim tab order
- [ ] Paired files are adjacent (no unrelated file between source and test)
- [ ] Unpaired files (source-only or test-only) are not dropped
- [ ] Existing filtering logic (status, existence, plan artifacts, filetypes) unchanged
- [ ] All behavioral tests pass
