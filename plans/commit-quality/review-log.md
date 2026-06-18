## Issue 03 — Plan Deletion Strategy

### Alleged literal tab/newline in git-commit-message.js
```javascript
const stagedFiles = _.chain(nameStatus)
  .split('\n')
  .compact()
  .map((line) => {
    const [status, path] = line.split('\t');
    return { path, status };
  })
  .value();
```
**Problem:** Both review agents flagged `'\n'` and `'\t'` as literal characters embedded in the string.
**Reason skipped:** False positive — the file uses proper escape sequences `'\n'` and `'\t'`, not literal characters. Reviewers were misled by diff rendering artifacts.

### Top-level staged-file parsing not extracted to a named module
**Problem:** Standards reviewer flagged the inline `repo.run()` / `_.chain()` block as violating the js-writer "one public named function per file" rule.
**Reason skipped:** Judgement call; `git-commit-message.js` is an entry-point script, not a library module. The same pattern (top-level awaits) is used throughout the file for `getCommitHint`, `callApi`, etc. Extracting a `getStagedFilesWithStatus.js` would be gold-plating beyond this issue's scope.
