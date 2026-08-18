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

## Issue 04 — TUI progress bar
### Theme module integration
```go
func New(ansiColor int) Model {
```
**Problem:** TUI package has no direct dependency on the theme module; accepts a raw int instead.
**Reason skipped:** Spec says "The TUI at this stage is standalone — it can be tested by feeding it fake progress events. Wiring to the actual git process comes in issue 05." Accepting an ANSI index is the correct decoupling boundary; issue 05 wiring will resolve colors from theme and pass them in.

## Issue 05 — Execute and wire
### Co-located Go test files
```go
// tui/tui_test.go, runner/runner_test.go
```
**Problem:** Test files use co-located `_test.go` pattern instead of `__tests__` directories.
**Reason skipped:** Go's test toolchain requires `_test.go` files in the same directory as the package under test. This is a language constraint, not a style choice.

### Only --repo special-cased as value flag
```go
if args[i] == "--repo" && i+1 < len(args) {
    i++
    flags = append(flags, args[i])
}
```
**Problem:** Other git push value-taking flags aren't handled, potentially misclassifying their values as positional args.
**Reason skipped:** git-branch-push's zparseopts only declares `--repo:` as a value flag. All other flags are boolean. No real gap.
