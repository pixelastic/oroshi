package diff

import (
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"
)

// LineKind represents the type of a line within a hunk.
type LineKind int

const (
	KindContext LineKind = iota
	KindAdded
	KindRemoved
)

// Marker represents the type of change on a line.
type Marker int

const (
	MarkerAdded    Marker = iota + 1
	MarkerModified
	MarkerDeleted
)

// DiffLine represents a single line within a hunk.
type DiffLine struct {
	Content string
	Kind    LineKind
}

// Hunk represents a contiguous block of changes.
type Hunk struct {
	OldStart int
	OldCount int
	NewStart int
	NewCount int
	Lines    []DiffLine
}

// FileDiff represents all changes to a single file.
type FileDiff struct {
	Path   string
	Hunks  []Hunk
	Binary bool
}

var hunkHeaderRegexp = regexp.MustCompile(`^@@ -(\d+),?(\d*) \+(\d+),?(\d*) @@`)

// Parse converts raw git diff output into structured FileDiff slices.
func Parse(raw string) []FileDiff {
	if strings.TrimSpace(raw) == "" {
		return []FileDiff{}
	}

	var result []FileDiff
	lines := strings.Split(raw, "\n")

	var current *FileDiff
	var currentHunk *Hunk

	for _, line := range lines {
		if strings.HasPrefix(line, "diff --git ") {
			if current != nil {
				if currentHunk != nil {
					current.Hunks = append(current.Hunks, *currentHunk)
					currentHunk = nil
				}
				result = append(result, *current)
			}
			path := extractPath(line)
			current = &FileDiff{Path: path}
			continue
		}

		if current == nil {
			continue
		}

		if strings.HasPrefix(line, "Binary files ") {
			current.Binary = true
			continue
		}

		// Symlinks diff as text (the link target), but their content is not worth
		// showing, like any other binary file
		if isSymlinkHeader(line) {
			current.Binary = true
			continue
		}

		if current.Binary {
			continue
		}

		matches := hunkHeaderRegexp.FindStringSubmatch(line)
		if matches != nil {
			if currentHunk != nil {
				current.Hunks = append(current.Hunks, *currentHunk)
			}
			currentHunk = &Hunk{
				OldStart: atoi(matches[1]),
				OldCount: atoiDefault(matches[2], 1),
				NewStart: atoi(matches[3]),
				NewCount: atoiDefault(matches[4], 1),
			}
			continue
		}

		if currentHunk == nil {
			continue
		}

		if strings.HasPrefix(line, "+") {
			currentHunk.Lines = append(currentHunk.Lines, DiffLine{
				Content: line[1:],
				Kind:    KindAdded,
			})
		} else if strings.HasPrefix(line, "-") {
			currentHunk.Lines = append(currentHunk.Lines, DiffLine{
				Content: line[1:],
				Kind:    KindRemoved,
			})
		} else if strings.HasPrefix(line, " ") {
			currentHunk.Lines = append(currentHunk.Lines, DiffLine{
				Content: line[1:],
				Kind:    KindContext,
			})
		}
	}

	if current != nil {
		if currentHunk != nil {
			current.Hunks = append(current.Hunks, *currentHunk)
		}
		result = append(result, *current)
	}

	for i := range result {
		markBinaryIfInvalidUTF8(&result[i])
	}

	return result
}

// markBinaryIfInvalidUTF8 flags files whose content is not valid UTF-8 as binary.
// Git only detects binary files by null bytes, so files filled with 0xFF
// (like emulator saves) otherwise render as garbage text.
func markBinaryIfInvalidUTF8(fileDiff *FileDiff) {
	for _, hunk := range fileDiff.Hunks {
		for _, line := range hunk.Lines {
			if utf8.ValidString(line.Content) {
				continue
			}
			fileDiff.Binary = true
			fileDiff.Hunks = nil
			return
		}
	}
}

// Classify analyzes hunks and assigns markers to new-side line numbers.
func Classify(hunks []Hunk) map[int]Marker {
	markers := make(map[int]Marker)

	for _, hunk := range hunks {
		classifyHunk(hunk, markers)
	}

	return markers
}

func classifyHunk(hunk Hunk, markers map[int]Marker) {
	// Build groups of consecutive removed and added lines
	type lineGroup struct {
		kind       LineKind
		startIndex int
		count      int
	}

	var groups []lineGroup
	for i, line := range hunk.Lines {
		if line.Kind == KindContext {
			continue
		}
		if len(groups) > 0 && groups[len(groups)-1].kind == line.Kind &&
			groups[len(groups)-1].startIndex+groups[len(groups)-1].count == i {
			groups[len(groups)-1].count++
		} else {
			groups = append(groups, lineGroup{kind: line.Kind, startIndex: i, count: 1})
		}
	}

	// Track which removed groups have adjacent added groups
	removedHasAdjacent := make(map[int]bool) // index in groups

	// Calculate new-side line number for each line index
	newLineNumber := func(targetIndex int) int {
		lineNum := hunk.NewStart
		for i, line := range hunk.Lines {
			if i == targetIndex {
				return lineNum
			}
			if line.Kind != KindRemoved {
				lineNum++
			}
		}
		return lineNum
	}

	// Process groups: pair removed+added as modified
	for i, group := range groups {
		if group.kind != KindAdded {
			continue
		}

		// Check if preceding group is removed (adjacent)
		hasAdjacentRemoved := false
		if i > 0 && groups[i-1].kind == KindRemoved {
			adjacentEnd := groups[i-1].startIndex + groups[i-1].count
			if adjacentEnd == group.startIndex {
				hasAdjacentRemoved = true
				removedHasAdjacent[i-1] = true
			}
		}

		removedCount := 0
		if hasAdjacentRemoved {
			removedCount = groups[i-1].count
		}

		for j := range group.count {
			lineIndex := group.startIndex + j
			lineNum := newLineNumber(lineIndex)
			if hasAdjacentRemoved && j < removedCount {
				markers[lineNum] = MarkerModified
			} else {
				markers[lineNum] = MarkerAdded
			}
		}
	}

	// Process orphaned removed groups
	for i, group := range groups {
		if group.kind != KindRemoved {
			continue
		}
		if removedHasAdjacent[i] {
			continue
		}

		// Place Deleted marker on nearest surviving new-side line
		targetLineNum := newLineNumber(group.startIndex)
		applyMarker(markers, targetLineNum, MarkerDeleted)
	}
}

func applyMarker(markers map[int]Marker, lineNumber int, marker Marker) {
	existing, exists := markers[lineNumber]
	if exists && priority(existing) >= priority(marker) {
		return
	}
	markers[lineNumber] = marker
}

func priority(marker Marker) int {
	switch marker {
	case MarkerModified:
		return 3
	case MarkerAdded:
		return 2
	case MarkerDeleted:
		return 1
	default:
		return 0
	}
}

func extractPath(diffLine string) string {
	// "diff --git a/path/to/file b/path/to/file" → "path/to/file"
	parts := strings.SplitN(diffLine, " b/", 2)
	if len(parts) < 2 {
		return ""
	}
	return parts[1]
}

func atoi(s string) int {
	n, _ := strconv.Atoi(s)
	return n
}

func atoiDefault(s string, defaultValue int) int {
	if s == "" {
		return defaultValue
	}
	return atoi(s)
}

// isSymlinkHeader reports whether a diff header line declares a symlink (git
// mode 120000), for new, deleted, modified or mode-changed files.
func isSymlinkHeader(line string) bool {
	if strings.HasPrefix(line, "index ") {
		return strings.HasSuffix(line, " 120000")
	}
	return line == "new file mode 120000" ||
		line == "deleted file mode 120000" ||
		line == "old mode 120000" ||
		line == "new mode 120000"
}
