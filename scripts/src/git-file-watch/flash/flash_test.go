package flash

import (
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/stretchr/testify/assert"
)

func marker(m diff.Marker) *diff.Marker { return &m }

// --- NewSnapshot ---

func TestNewSnapshotOnlyIncludesMarkedRows(t *testing.T) {
	rows := []layout.Row{
		layout.LineRow{FilePath: "a.go", LineNumber: 1, Marker: marker(diff.MarkerAdded)},
		layout.LineRow{FilePath: "a.go", LineNumber: 2, Marker: nil},
		layout.LineRow{FilePath: "a.go", LineNumber: 3, Marker: marker(diff.MarkerModified)},
	}
	rawLines := map[string][]string{
		"a.go": {"line1", "line2", "line3"},
	}

	snap := NewSnapshot(rows, rawLines)

	assert.Len(t, snap.Lines, 2)
	assert.Equal(t, "line1", snap.Lines["a.go:1"])
	assert.Equal(t, "line3", snap.Lines["a.go:3"])
}

// --- DetectChangedLines ---

func TestDetectChangedLinesReturnsNilForNilPrev(t *testing.T) {
	current := Snapshot{
		Lines:      map[string]string{"a.go:1": "content"},
		ContentSet: map[string]map[string]bool{"a.go": {"content": true}},
	}

	result := DetectChangedLines(nil, current)

	assert.Nil(t, result)
}

func TestDetectChangedLinesReturnsNewContent(t *testing.T) {
	prev := &Snapshot{
		Lines:      map[string]string{"a.go:1": "old"},
		ContentSet: map[string]map[string]bool{"a.go": {"old": true}},
	}
	current := Snapshot{
		Lines:      map[string]string{"a.go:1": "old", "a.go:2": "new"},
		ContentSet: map[string]map[string]bool{"a.go": {"old": true, "new": true}},
	}

	result := DetectChangedLines(prev, current)

	assert.True(t, result["a.go:2"])
	assert.False(t, result["a.go:1"])
}
