package render

import (
	"strings"
	"unicode/utf8"
)

// SimplifyPath shortens a path by keeping segments from both ends with "…" in
// the middle. maxDisplay is clamped to a minimum of 4. Paths with fewer
// segments than maxDisplay are returned unchanged.
func SimplifyPath(path string, maxDisplay int) string {
	if maxDisplay < 4 {
		maxDisplay = 4
	}

	segments := strings.Split(path, "/")
	if len(segments) <= maxDisplay {
		return path
	}

	left := (maxDisplay - 1) / 2
	right := maxDisplay - 1 - left

	out := make([]string, 0, maxDisplay)
	out = append(out, segments[:left]...)
	out = append(out, "…")
	out = append(out, segments[len(segments)-right:]...)
	return strings.Join(out, "/")
}

// FitPath returns the path unchanged if it fits within maxWidth characters.
// Otherwise it progressively removes intermediate directory segments (one at a
// time) until the path fits. Stops at a minimum of 4 displayed segments.
// Returns the best-effort result if even the minimum doesn't fit.
// A maxWidth of 0 or less disables truncation.
func FitPath(path string, maxWidth int) string {
	if maxWidth <= 0 || utf8.RuneCountInString(path) <= maxWidth {
		return path
	}

	segments := strings.Count(path, "/") + 1
	for display := segments - 1; display >= 4; display-- {
		candidate := SimplifyPath(path, display)
		if utf8.RuneCountInString(candidate) <= maxWidth {
			return candidate
		}
	}

	return SimplifyPath(path, 4)
}
