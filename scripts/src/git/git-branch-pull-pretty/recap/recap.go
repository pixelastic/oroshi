// Package recap builds the summary lines printed after a pull.
package recap

import (
	"fmt"
	"strings"

	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
)

// Styler renders branch and tag names for display.
type Styler interface {
	Branch(name string) string
	Tag(name string) string
}

// Input holds everything the recap needs.
// Commits is the number of new commits by branch name.
// Diffstat belongs to CurrentBranch and is printed only when that branch changed.
// SwitchedTo is the branch checked out by the pull, if it was another one. No
// diffstat is printed in that case.
type Input struct {
	Events        []parser.Event
	Commits       map[string]int
	CurrentBranch string
	Diffstat      string
	SwitchedTo    string
}

// Lines returns the recap lines, or a single "Already up to date" line when
// no event changed a branch or a tag. The switch line, if any, comes last.
func Lines(input Input, style Styler) []string {
	var lines []string
	var tags []string

	for _, event := range input.Events {
		switch event.Type {
		case parser.BranchUpdate:
			lines = append(lines, branchLine(event, input.Commits[event.Branch], style))
			if input.SwitchedTo == "" && event.Branch == input.CurrentBranch && input.Diffstat != "" {
				lines = append(lines, strings.Split(input.Diffstat, "\n")...)
			}
		case parser.NewTag:
			tags = append(tags, style.Tag(event.Tag))
		}
	}

	if len(tags) > 0 {
		lines = append(lines, "Tags: "+strings.Join(tags, " "))
	}
	if len(lines) == 0 {
		lines = []string{"Already up to date"}
	}
	if input.SwitchedTo != "" {
		lines = append(lines, "Switched to "+style.Branch(input.SwitchedTo))
	}
	return lines
}

func branchLine(event parser.Event, commits int, style Styler) string {
	parts := []string{style.Branch(event.Branch)}
	if event.New {
		parts = append(parts, "new")
	}
	if commits > 0 {
		parts = append(parts, commitCount(commits))
	}
	if event.Forced {
		parts = append(parts, "forced")
	}
	return strings.Join(parts, " ")
}

func commitCount(count int) string {
	if count == 1 {
		return "+1 commit"
	}
	return fmt.Sprintf("+%d commits", count)
}
