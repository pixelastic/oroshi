package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/comments"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/highlight"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/navigation"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/render"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/theme"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- buildCommentIndex ---

func TestBuildCommentIndexMapsKeyToReviewText(t *testing.T) {
	input := []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 10, Review: "needs refactor"},
	}

	index := buildCommentIndex(input, "/repo")

	assert.Equal(t, "needs refactor", index["file.go:10"])
}

func TestBuildCommentIndexReturnsEmptyMapForNoComments(t *testing.T) {
	index := buildCommentIndex(nil, "/repo")

	assert.Empty(t, index)
}

func TestBuildCommentIndexHandlesMultipleComments(t *testing.T) {
	input := []comments.Comment{
		{Filepath: "/repo/a.go", LineNumber: 1, Review: "first"},
		{Filepath: "/repo/b.go", LineNumber: 2, Review: "second"},
	}

	index := buildCommentIndex(input, "/repo")

	assert.Equal(t, "first", index["a.go:1"])
	assert.Equal(t, "second", index["b.go:2"])
}

// --- View: empty state ---

func TestViewShowsNoChangesWhenEmpty(t *testing.T) {
	th := loadTestTheme(t)
	m := model{
		theme: th,
		rows:  []layout.Row{},
		nav:   navigation.State{ViewportHeight: 40},
	}

	output := m.View()

	assert.Contains(t, output, "No changes")
}

// --- View: file header ---

func TestViewRendersFileHeaderWithDirectoryAndFilename(t *testing.T) {
	th := loadTestTheme(t)
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "src/pkg/file.go"},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.Contains(t, output, "file.go")
	assert.Contains(t, output, "src/pkg/")
}

func TestViewIndentsFileHeaderWithSpace(t *testing.T) {
	th := loadTestTheme(t)
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.Contains(t, output, " file.go")
}

func TestViewRendersFirstFileHeaderWithLeadingEmptyLine(t *testing.T) {
	th := loadTestTheme(t)
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.True(t, strings.HasPrefix(output, "\n"), "first file header should have a leading empty line")
}

// --- View: horizontal separator between files ---

func TestViewRendersSeparatorBetweenFiles(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
		layout.FileHeaderRow{Path: "b.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.Contains(t, output, "─")
}

func TestViewDoesNotRenderSeparatorBeforeFirstFile(t *testing.T) {
	th := loadTestTheme(t)
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.NotContains(t, output, "─")
}

// --- View: gutter on code lines ---

func TestViewRendersGutterOnCodeLines(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.Contains(t, output, "▌")
}

// --- View: comment rendering ---

func TestViewRendersCommentAboveLine(t *testing.T) {
	th := loadTestTheme(t)
	repoRoot := "/repo"
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModelWithRoot(th, rows, repoRoot)
	m.commentIndex = map[string]string{
		"file.go:10": "looks wrong",
	}

	output := m.View()

	assert.Contains(t, output, "REVIEW: looks wrong")
}

func TestViewRendersCommentGutterBar(t *testing.T) {
	th := loadTestTheme(t)
	repoRoot := "/repo"
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModelWithRoot(th, rows, repoRoot)
	m.commentIndex = map[string]string{
		"file.go:10": "fix this",
	}

	output := m.View()

	lines := strings.Split(output, "\n")
	for _, line := range lines {
		if strings.Contains(line, "REVIEW:") {
			assert.Contains(t, line, "▌")
			return
		}
	}
	t.Fatal("no REVIEW line found in output")
}

func TestViewRendersCommentBeforeCodeLine(t *testing.T) {
	th := loadTestTheme(t)
	repoRoot := "/repo"
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModelWithRoot(th, rows, repoRoot)
	m.commentIndex = map[string]string{
		"file.go:10": "check this",
	}

	output := m.View()

	reviewIdx := strings.Index(output, "REVIEW:")
	lineNumIdx := strings.LastIndex(output, "10")
	require.Greater(t, reviewIdx, -1, "REVIEW line should exist")
	require.Greater(t, lineNumIdx, -1, "line number should exist")
	assert.Less(t, reviewIdx, lineNumIdx, "REVIEW should appear before the line number")
}

func TestViewDoesNotRenderReviewWhenNoComment(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)

	output := m.View()

	assert.NotContains(t, output, "REVIEW:")
}

// --- Helpers ---

func loadTestTheme(t *testing.T) *theme.Theme {
	t.Helper()
	root := t.TempDir()
	dir := filepath.Join(root, "tools", "term", "zsh", "config", "theming", "dist")
	require.NoError(t, os.MkdirAll(dir, 0o755))

	colors := map[string]map[string]interface{}{
		"git-added":    {"ansi": 40, "hex": "#00d700"},
		"git-modified": {"ansi": 135, "hex": "#af5fff"},
		"git-removed":  {"ansi": 196, "hex": "#ff0000"},
		"orange":       {"ansi": 208, "hex": "#ff8700"},
		"gray":         {"ansi": 245, "hex": "#6b7280"},
		"gray-5":       {"ansi": 240, "hex": "#4b5563"},
		"gray-7":       {"ansi": 236, "hex": "#374151"},
		"gray-9":       {"ansi": 234, "hex": "#1f2937"},
		"directory":    {"ansi": 35, "hex": "#38a169"},
		"yellow":       {"ansi": 226, "hex": "#facc15"},
		"amber-3":      {"ansi": 214, "hex": "#fbbf24"},
	}
	data, err := json.Marshal(colors)
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "colors.json"), data, 0o644))

	th, err := theme.Load(root)
	require.NoError(t, err)
	return th
}

func testModel(th *theme.Theme, rows []layout.Row) model {
	return testModelWithRoot(th, rows, "/repo")
}

func testModelWithRoot(th *theme.Theme, rows []layout.Row, repoRoot string) model {
	fileIndex := findFileHeaders(rows, nil)
	visibleIndices := navigation.VisibleIndices(len(rows), fileIndex)
	return model{
		theme:           th,
		rows:            rows,
		highlighted:     map[string][]highlight.StyledLine{},
		rawLines:        map[string][]string{},
		repoRoot:        repoRoot,
		fileIndex:       fileIndex,
		visibleIndices:  visibleIndices,
		commentIndex:    map[string]string{},
		flashLines:      map[string]bool{},
		lineNumberWidth: render.MaxLineNumberWidth(rows),
		nav: navigation.State{
			RowCount:       len(rows),
			ViewportHeight: 40,
		},
	}
}
