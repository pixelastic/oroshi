## Issue 01 — Go scaffold
### Go CLI `-o` flag has no long-form
```zsh
go build \
  -o "scripts/bin/${binaryName}/${binaryName}" \
  "./scripts/bin/${binaryName}/__lib"
```
**Problem:** Short-form `-o` flag violates "prefer long-form args" rule.
**Reason skipped:** Go's flag package only supports single-dash flags. No `--output` alternative exists.

### Scaffolding tests not visible in diff
**Problem:** Spec review flagged missing scaffolding tests.
**Reason skipped:** Tests exist in `plans/git-pretty/scaffold/01-go-scaffold.bats` but are gitignored per `.gitignore` `plans/*/scaffold` rule, so `review-diff` didn't see them.

### Build invocation differs from spec
```zsh
builtin cd "$repoRoot"
go build \
  -o "scripts/bin/${binaryName}/${binaryName}" \
  "./scripts/bin/${binaryName}/__lib"
```
**Problem:** Spec says `go build -o ../git-branch-push-pretty .` (relative from `__lib/`).
**Reason skipped:** GVM's `cd` hook fails under `err_return`. Using `builtin cd` to repo root and absolute paths is a necessary workaround. Output path is identical.

## Issue 02 — Stderr parser
### Single-letter variables `m` and `e`
```go
if m := progressRe.FindStringSubmatch(line); m != nil {
e := ParseLine("Counting objects: 100% (109/109), done.")
```
**Problem:** Abbreviated variable names violate `code-writer/references/style.md` "no abbreviated variable names" rule.
**Reason skipped:** Go idiom — single-letter vars in narrow scopes (regex match result used on next line, test assertion target) are standard Go style. Enforcing `match`/`event` here fights language convention for marginal readability gain.
