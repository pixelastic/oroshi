## TLDR

Manual smoke test: push to a local bare remote and verify the TUI renders correctly.

## What to do

No code to write — this is a manual verification checkpoint.

1. Create a local bare remote:
   ```
   git init --bare /tmp/push-pretty-test
   git remote add test-pretty /tmp/push-pretty-test
   ```

2. Generate enough data to make progress visible:
   ```
   dd if=/dev/urandom of=blob.bin bs=1M count=50
   git add blob.bin && git commit -m "test blob"
   ```

3. Build the binary:
   ```
   scripts/bin/git-branch-push-pretty/__lib/build
   ```

4. Run the push through the pretty wrapper:
   ```
   scripts/bin/git-branch-push-pretty/git-branch-push-pretty test-pretty
   ```

5. Verify:
   - Progress bar renders with phase name, bar, and percentage
   - Phases transition (Counting → Compressing → Writing)
   - Ctrl+C kills cleanly
   - A second push shows "Everything up-to-date" confirmation

6. Clean up:
   ```
   git remote remove test-pretty
   rm -rf /tmp/push-pretty-test
   git reset HEAD~ && rm blob.bin
   ```

## Acceptance criteria

- [ ] Progress bar visually fills during push
- [ ] Phase names update in real-time
- [ ] Colors render from theme
- [ ] Ctrl+C kills both TUI and git subprocess
- [ ] "Up to date" case works on second push
