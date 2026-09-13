package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/bar"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/theme"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/tree"
)

func main() {
	args := os.Args[1:]
	if len(args) != 3 {
		fmt.Fprintln(os.Stderr, "Usage: git-commit-diffstat <from> <to> <repo>")
		os.Exit(1)
	}

	from, to, repo := args[0], args[1], args[2]

	oroshiRoot := os.Getenv("OROSHI_ROOT")
	if oroshiRoot == "" {
		fmt.Fprintln(os.Stderr, "OROSHI_ROOT not set")
		os.Exit(1)
	}

	thm, err := theme.Load(oroshiRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	changes, err := diff.Query(from, to, repo, execRunner)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	if len(changes) == 0 {
		return
	}

	barColors := bar.Colors{
		Added:    thm.Lipgloss("git-added"),
		Removed:  thm.Lipgloss("git-removed"),
		Modified: thm.Lipgloss("git-modified"),
	}
	barRenderer := func(change diff.FileChange) string {
		return bar.Render(change.Additions, change.Deletions, change.Status, change.IsBinary, barColors)
	}

	t := tree.Build(changes)
	fmt.Print(tree.Render(t, thm, barRenderer))
}

func execRunner(name string, args ...string) (string, error) {
	out, err := exec.Command(name, args...).Output()
	if err != nil {
		return "", err
	}
	return strings.TrimRight(string(out), "\n"), nil
}
