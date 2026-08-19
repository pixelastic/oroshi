package parser

import (
	"regexp"
	"strconv"
	"strings"
)

// EventType classifies a git push stderr line.
type EventType int

const (
	Progress EventType = iota
	RefUpdate
	RemoteMessage
	Error
	UpToDate
	Noise
)

// Event represents a parsed git push stderr line.
type Event struct {
	Type        EventType
	Phase       string
	Current     int
	Total       int
	Percentage  int
	FromRef     string
	ToRef       string
	Branch      string
	Remote string
	Forced      bool
	Raw         string
}

var progressRe = regexp.MustCompile(`^(.+?):\s+(\d+)%\s+\((\d+)/(\d+)\)`)
var refUpdateRe = regexp.MustCompile(`^\s+\+?\s*([0-9a-f]+)\.{2,3}([0-9a-f]+)\s+(\S+)\s+->\s+\S+`)
var destinationRe = regexp.MustCompile(`^To\s+(.+)$`)

// ParseLine classifies a single git push stderr line into a typed Event.
func ParseLine(line string) Event {
	// Handle \r as line delimiter: last segment wins (git overwrites in-place)
	if i := strings.LastIndex(line, "\r"); i >= 0 {
		line = line[i+1:]
	}

	// Strip "remote: " prefix, then check for progress inside
	if strings.HasPrefix(line, "remote: ") {
		inner := strings.TrimPrefix(line, "remote: ")
		if m := progressRe.FindStringSubmatch(inner); m != nil {
			return parseProgress(m)
		}
		return Event{Type: RemoteMessage, Raw: inner}
	}

	if strings.HasPrefix(line, "! ") {
		return Event{Type: Error, Raw: strings.TrimPrefix(line, "! ")}
	}
	if strings.HasPrefix(line, "fatal: ") {
		return Event{Type: Error, Raw: strings.TrimPrefix(line, "fatal: ")}
	}
	if strings.HasPrefix(line, "error: ") {
		return Event{Type: Error, Raw: strings.TrimPrefix(line, "error: ")}
	}

	if line == "Everything up-to-date" {
		return Event{Type: UpToDate}
	}

	if m := progressRe.FindStringSubmatch(line); m != nil {
		return parseProgress(m)
	}

	if m := destinationRe.FindStringSubmatch(line); m != nil {
		return Event{Type: RefUpdate, Remote: m[1]}
	}

	if m := refUpdateRe.FindStringSubmatch(line); m != nil {
		forced := strings.Contains(line, "(forced update)")
		return Event{Type: RefUpdate, FromRef: m[1], ToRef: m[2], Branch: m[3], Forced: forced}
	}

	return Event{Type: Noise}
}

func parseProgress(m []string) Event {
	percentage, _ := strconv.Atoi(m[2])
	current, _ := strconv.Atoi(m[3])
	total, _ := strconv.Atoi(m[4])
	return Event{Type: Progress, Phase: m[1], Percentage: percentage, Current: current, Total: total}
}
