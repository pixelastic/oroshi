package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/bar"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/diff"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/theme"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/tree"
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

	thm, err := theme.Load(oroshiRoot, execRunner)
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
	fmt.Print(tree.Render(t, pathTheme{thm}, barRenderer))
}

// pathTheme adapts the shared theme to tree.ThemeResolver, which colors files by path only.
type pathTheme struct {
	*theme.Theme
}

func (p pathTheme) FiletypeColor(path string) lipgloss.Color {
	color, _ := p.Theme.FiletypeColor(path, "")
	return color
}

func execRunner(name string, args ...string) (string, error) {
	out, err := exec.Command(name, args...).Output()
	if err != nil {
		return "", err
	}
	return strings.TrimRight(string(out), "\n"), nil
}
