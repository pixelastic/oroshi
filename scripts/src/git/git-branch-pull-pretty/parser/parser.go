// Package parser classifies the stderr lines of `git fetch --progress`.
package parser

import (
	"regexp"
	"strconv"
	"strings"
)

// EventType classifies a git fetch stderr line.
type EventType int

const (
	Noise EventType = iota
	Progress
	BranchUpdate
	NewTag
	Error
)

// Event represents a parsed git fetch stderr line.
type Event struct {
	Type       EventType
	Phase      string
	Percentage int
	Branch     string
	FromRef    string
	ToRef      string
	New        bool
	Forced     bool
	Tag        string
	Raw        string
}

var (
	progressRe     = regexp.MustCompile(`^(.+?):\s+(\d+)%\s+\(\d+/\d+\)`)
	branchUpdateRe = regexp.MustCompile(`^\s+\+?\s*([0-9a-f]+)\.{2,3}([0-9a-f]+)\s+(\S+)\s+->\s+\S+`)
	newBranchRe    = regexp.MustCompile(`^\s+\*\s+\[new branch\]\s+(\S+)\s+->\s+\S+`)
	newTagRe       = regexp.MustCompile(`^\s+\*\s+\[new tag\]\s+(\S+)\s+->\s+\S+`)
)

// ParseLine classifies a single git fetch stderr line into a typed Event.
func ParseLine(line string) Event {
	// Git overwrites progress in place with \r, so the last segment wins
	if i := strings.LastIndex(line, "\r"); i >= 0 {
		line = line[i+1:]
	}
	line = strings.TrimPrefix(line, "remote: ")

	for _, prefix := range []string{"fatal: ", "error: "} {
		if strings.HasPrefix(line, prefix) {
			return Event{Type: Error, Raw: strings.TrimPrefix(line, prefix)}
		}
	}

	if m := progressRe.FindStringSubmatch(line); m != nil {
		percentage, _ := strconv.Atoi(m[2])
		return Event{Type: Progress, Phase: m[1], Percentage: percentage}
	}

	if m := newBranchRe.FindStringSubmatch(line); m != nil {
		return Event{Type: BranchUpdate, Branch: m[1], New: true}
	}

	if m := newTagRe.FindStringSubmatch(line); m != nil {
		return Event{Type: NewTag, Tag: m[1]}
	}

	if m := branchUpdateRe.FindStringSubmatch(line); m != nil {
		forced := strings.Contains(line, "(forced update)")
		return Event{Type: BranchUpdate, Branch: m[3], FromRef: m[1], ToRef: m[2], Forced: forced}
	}

	return Event{Type: Noise}
}
