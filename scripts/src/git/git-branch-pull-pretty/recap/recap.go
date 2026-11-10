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
type Input struct {
	Events        []parser.Event
	Commits       map[string]int
	CurrentBranch string
	Diffstat      string
}

// Lines returns the recap lines, or a single "Already up to date" line when
// no event changed a branch or a tag.
func Lines(input Input, style Styler) []string {
	var lines []string
	var tags []string

	for _, event := range input.Events {
		switch event.Type {
		case parser.BranchUpdate:
			lines = append(lines, branchLine(event, input.Commits[event.Branch], style))
			if event.Branch == input.CurrentBranch && input.Diffstat != "" {
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
		return []string{"Already up to date"}
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
