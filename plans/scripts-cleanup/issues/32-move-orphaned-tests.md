## TLDR

Move orphaned test files from `scripts/bin/` to their correct autoload locations.

## What to build

Move `scripts/bin/ai/review-blog/__tests__/review-blog-start.bats` to `tools/term/zsh/config/functions/autoload/ai/__tests__/review-blog-start.bats`.
- Create `ai/__tests__/` if it doesn't exist
- Verify tests still pass after move

Move `scripts/bin/__tests__/table.bats` to `tools/term/zsh/config/functions/autoload/misc/__tests__/table.bats`.
- Verify tests still pass after move

Delete empty directories after moves:
- `scripts/bin/ai/review-blog/__tests__/`
- `scripts/bin/ai/review-blog/`
- `scripts/bin/ai/`

## Scaffolding Tests

- `review-blog-start.bats` exists in autoload `ai/__tests__/`
- `table.bats` exists in autoload `misc/__tests__/`
- No test files remain in `scripts/bin/ai/` or `scripts/bin/__tests__/table.bats`

## Acceptance criteria

- [ ] `review-blog-start.bats` moved to `ai/__tests__/`
- [ ] `table.bats` moved to `misc/__tests__/`
- [ ] Both test files pass in their new locations
- [ ] Empty directories cleaned up
- [ ] `scripts/bin/__tests__/` only contains `bin-zsh.bats`
