package diff

import (
	"fmt"
	"strconv"
	"strings"
)

// CommandRunner executes an external command and returns its stdout output.
type CommandRunner func(name string, args ...string) (string, error)

// Status represents the type of change applied to a file.
type Status int

const (
	Added Status = iota
	Modified
	Deleted
	Renamed
)

// FileChange holds structured diff data for a single file.
type FileChange struct {
	Path      string
	OldPath   string // non-empty only for renames
	Status    Status
	Additions int
	Deletions int
	IsBinary  bool
}

// numstatEntry holds parsed output from git diff --numstat.
type numstatEntry struct {
	path      string
	oldPath   string // non-empty for renames (tab-separated old\tnew)
	additions int
	deletions int
	isBinary  bool
}

// nameStatusEntry holds parsed output from git diff --name-status.
type nameStatusEntry struct {
	path    string
	oldPath string // non-empty for renames
	status  Status
}

// Query returns structured diff data between two refs in the given repo.
func Query(from, to, repoPath string, runner CommandRunner) ([]FileChange, error) {
	numstatOutput, err := runner("git", "-C", repoPath, "diff", "--numstat", from, to, "--")
	if err != nil {
		return nil, fmt.Errorf("running git diff --numstat: %w", err)
	}

	nameStatusOutput, err := runner("git", "-C", repoPath, "diff", "--name-status", "-C", from, to, "--")
	if err != nil {
		return nil, fmt.Errorf("running git diff --name-status: %w", err)
	}

	numstats := parseNumstat(numstatOutput)
	nameStatuses := parseNameStatus(nameStatusOutput)

	return merge(numstats, nameStatuses), nil
}

func parseNumstat(output string) []numstatEntry {
	var entries []numstatEntry
	for _, line := range strings.Split(output, "\n") {
		if line == "" {
			continue
		}
		entry, ok := parseNumstatLine(line)
		if !ok {
			continue
		}
		entries = append(entries, entry)
	}
	return entries
}

func parseNumstatLine(line string) (numstatEntry, bool) {
	parts := strings.Split(line, "\t")
	if len(parts) < 3 {
		return numstatEntry{}, false
	}

	// Binary files show as "-\t-\t<path>"
	if parts[0] == "-" && parts[1] == "-" {
		return numstatEntry{
			path:     parts[2],
			isBinary: true,
		}, true
	}

	additions, err := strconv.Atoi(parts[0])
	if err != nil {
		return numstatEntry{}, false
	}
	deletions, err := strconv.Atoi(parts[1])
	if err != nil {
		return numstatEntry{}, false
	}

	entry := numstatEntry{
		additions: additions,
		deletions: deletions,
	}

	// Renames show as "0\t0\told\tnew"
	if len(parts) == 4 {
		entry.oldPath = parts[2]
		entry.path = parts[3]
	} else {
		entry.path = parts[2]
	}

	return entry, true
}

func parseNameStatus(output string) []nameStatusEntry {
	var entries []nameStatusEntry
	for _, line := range strings.Split(output, "\n") {
		if line == "" {
			continue
		}
		entry, ok := parseNameStatusLine(line)
		if !ok {
			continue
		}
		entries = append(entries, entry)
	}
	return entries
}

func parseNameStatusLine(line string) (nameStatusEntry, bool) {
	parts := strings.Split(line, "\t")
	if len(parts) < 2 {
		return nameStatusEntry{}, false
	}

	statusCode := parts[0]
	entry := nameStatusEntry{}

	switch {
	case statusCode == "A":
		entry.status = Added
		entry.path = parts[1]
	case statusCode == "M":
		entry.status = Modified
		entry.path = parts[1]
	case statusCode == "D":
		entry.status = Deleted
		entry.path = parts[1]
	case strings.HasPrefix(statusCode, "R"):
		entry.status = Renamed
		if len(parts) < 3 {
			return nameStatusEntry{}, false
		}
		entry.oldPath = parts[1]
		entry.path = parts[2]
	default:
		return nameStatusEntry{}, false
	}

	return entry, true
}

// merge combines numstat and name-status data, keyed by path.
func merge(numstats []numstatEntry, nameStatuses []nameStatusEntry) []FileChange {
	if len(nameStatuses) == 0 {
		return nil
	}

	numstatByPath := make(map[string]numstatEntry, len(numstats))
	for _, entry := range numstats {
		numstatByPath[entry.path] = entry
	}

	changes := make([]FileChange, 0, len(nameStatuses))
	for _, ns := range nameStatuses {
		change := FileChange{
			Path:    ns.path,
			OldPath: ns.oldPath,
			Status:  ns.status,
		}
		if num, ok := numstatByPath[ns.path]; ok {
			change.Additions = num.additions
			change.Deletions = num.deletions
			change.IsBinary = num.isBinary
		}
		changes = append(changes, change)
	}

	return changes
}
