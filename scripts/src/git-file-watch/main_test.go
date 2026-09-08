package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/comments"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/editing"
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

	assert.Contains(t, output, "    No changes")
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

// --- Initial cursor position ---

func TestFirstMarkedRowIndexReturnsFirstModifiedLine(t *testing.T) {
	marker := diff.MarkerModified
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Distance: 2},
		layout.LineRow{LineNumber: 2, Marker: &marker},
		layout.LineRow{LineNumber: 3, Distance: 1},
	}

	result := firstMarkedRowIndex(rows)

	assert.Equal(t, 2, result)
}

func TestFirstMarkedRowIndexReturnsZeroWhenNoMarkers(t *testing.T) {
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Distance: 2},
	}

	result := firstMarkedRowIndex(rows)

	assert.Equal(t, 0, result)
}

// --- Keybinding: gg (go to top) ---

func TestGGMovesToFirstCodeLine(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
		layout.LineRow{LineNumber: 2, Marker: &marker},
		layout.LineRow{LineNumber: 3, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 3

	m1, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'g'}})
	m2, _ := m1.(model).updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'g'}})
	result := m2.(model)

	// Should land on first LineRow (index 1), not FileHeaderRow (index 0)
	assert.Equal(t, 1, result.nav.Cursor)
}

// --- Keybinding: G (go to bottom) ---

func TestShiftGMovesToBottomRow(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
		layout.LineRow{LineNumber: 2, Marker: &marker},
		layout.LineRow{LineNumber: 3, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 0

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'G'}})
	resultModel := result.(model)

	assert.Equal(t, 3, resultModel.nav.Cursor)
}

// --- Cursor skips non-code rows ---

func TestCursorSkipsFileHeaderWhenMovingDown(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},          // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.FileHeaderRow{Path: "b.go"},          // 2
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 3
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}})
	resultModel := result.(model)

	// Should skip the FileHeaderRow at index 2 and land on index 3
	assert.Equal(t, 3, resultModel.nav.Cursor)
}

func TestCursorSkipsFileHeaderWhenMovingUp(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},          // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.FileHeaderRow{Path: "b.go"},          // 2
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 3
	}
	m := testModel(th, rows)
	m.nav.Cursor = 3

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'k'}})
	resultModel := result.(model)

	// Should skip the FileHeaderRow at index 2 and land on index 1
	assert.Equal(t, 1, resultModel.nav.Cursor)
}

func TestCursorSkipsSeparatorWhenMovingDown(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},          // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.SeparatorRow{},                       // 2
		layout.LineRow{LineNumber: 10, Marker: &marker}, // 3
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}})
	resultModel := result.(model)

	// Should skip the SeparatorRow at index 2 and land on index 3
	assert.Equal(t, 3, resultModel.nav.Cursor)
}

func TestGGLandsOnFirstCodeLine(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},          // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.LineRow{LineNumber: 2, Marker: &marker}, // 2
	}
	m := testModel(th, rows)
	m.nav.Cursor = 2

	m1, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'g'}})
	m2, _ := m1.(model).updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'g'}})
	resultModel := m2.(model)

	// Should land on first LineRow (index 1), not the FileHeaderRow (index 0)
	assert.Equal(t, 1, resultModel.nav.Cursor)
}

// --- Fold does not scroll viewport ---

func TestFoldingSecondFileKeepsFirstFileVisible(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},              // 0
		layout.LineRow{LineNumber: 1, Marker: &marker},  // 1
		layout.LineRow{LineNumber: 2, Marker: &marker},  // 2
		layout.LineRow{LineNumber: 3, Marker: &marker},  // 3
		layout.LineRow{LineNumber: 4, Marker: &marker},  // 4
		layout.FileHeaderRow{Path: "b.go"},              // 5
		layout.LineRow{LineNumber: 1, Marker: &marker},  // 6
		layout.LineRow{LineNumber: 2, Marker: &marker},  // 7
		layout.LineRow{LineNumber: 3, Marker: &marker},  // 8
		layout.LineRow{LineNumber: 4, Marker: &marker},  // 9
	}
	m := testModel(th, rows)
	m.nav.ViewportHeight = 4

	// Fold file a — cursor advances to first line of file b
	// Viewport stays on file a's header so the fold is visible
	m.nav.Cursor = 2
	m.pendingKey = "z"
	r1, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'a'}})
	m = r1.(model)
	assert.Equal(t, 6, m.nav.Cursor)
	assert.Equal(t, 0, m.nav.ViewportOffset, "folded file a header should be visible")

	// Navigate down to file b's last line — this scrolls the viewport
	m.nav.Cursor = 9
	m.nav.ViewportOffset = 6

	// Fold file b — last file, cursor stays on header 5
	m.pendingKey = "z"
	r2, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'a'}})
	m = r2.(model)

	assert.Equal(t, 5, m.nav.Cursor)
	// After folding, both headers (0 and 5) should be visible
	// Viewport should scroll back to show file a's header
	assert.Equal(t, 0, m.nav.ViewportOffset)
}

// --- Cursor lands on folded file header ---

func TestCursorCanLandOnFoldedFileHeader(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},             // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.FileHeaderRow{Path: "b.go"},             // 2 (folded)
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 3 (hidden by fold)
	}
	m := testModel(th, rows)
	m.fileIndex.FoldState["b.go"] = true
	m.refreshIndices()
	m.nav.Cursor = 1

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}})
	resultModel := result.(model)

	// Should land on the folded file header at index 2
	assert.Equal(t, 2, resultModel.nav.Cursor)
}

func TestCursorSkipsUnfoldedFileHeader(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "a.go"},             // 0
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 1
		layout.FileHeaderRow{Path: "b.go"},             // 2 (not folded)
		layout.LineRow{LineNumber: 1, Marker: &marker}, // 3
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'j'}})
	resultModel := result.(model)

	// Should skip header at 2 and land on code line at 3
	assert.Equal(t, 3, resultModel.nav.Cursor)
}

// --- Keybinding: ctrl+s (auto-commit) ---

func TestCtrlSInNormalModeReturnsExecCommand(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1

	_, cmd := m.updateNormal(tea.KeyMsg{Type: tea.KeyCtrlS})

	assert.NotNil(t, cmd, "ctrl+s should return a command to exec the commit process")
}

func TestCtrlSInNormalModeDoesNotMoveCursor(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
		layout.LineRow{LineNumber: 2, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 2

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyCtrlS})
	resultModel := result.(model)

	assert.Equal(t, 2, resultModel.nav.Cursor)
}

func TestCommitFinishedMsgRebuildsDisplay(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)

	result, _ := m.Update(CommitFinishedMsg{err: nil})
	resultModel := result.(model)

	// Model should still be valid after handling CommitFinishedMsg
	assert.NotNil(t, resultModel.theme)
}

func TestReloadCommentsDoesNotWriteFile(t *testing.T) {
	th := loadTestTheme(t)
	m := testModel(th, []layout.Row{})
	commentsPath := filepath.Join(t.TempDir(), "comments.json")
	require.NoError(t, os.WriteFile(commentsPath, []byte(`[{"id":"abc","filepath":"/repo/file.go","lineNumber":1,"lineContent":"x","review":"test","commitHash":"h"}]`), 0o644))
	m.commentsPath = commentsPath

	info1, err := os.Stat(commentsPath)
	require.NoError(t, err)

	m.Update(CommentsChangedMsg{})

	info2, err := os.Stat(commentsPath)
	require.NoError(t, err)
	assert.Equal(t, info1.ModTime(), info2.ModTime(), "reloadComments should not write back to the comments file (would trigger infinite watcher loop)")
}

func TestEnterInEditModeSavesComment(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.editState = editing.Open("/repo/file.go", 1, "content", "", 1)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, cmd := m.Update(tea.KeyMsg{Type: tea.KeyEnter})
	resultModel := result.(model)

	assert.Nil(t, cmd, "enter in edit mode should save comment, not exec a process")
	assert.False(t, resultModel.editState.Active, "edit mode should be closed after enter")
}

func TestCtrlDInEditModeCancelsWithoutSaving(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.editState = editing.Open("/repo/file.go", 1, "content", "old review", 1)
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, LineContent: "content", Review: "old review"},
	}
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.Update(tea.KeyMsg{Type: tea.KeyCtrlD})
	resultModel := result.(model)

	assert.False(t, resultModel.editState.Active, "edit mode should be closed after ctrl+d")
	assert.Equal(t, "old review", resultModel.userComments[0].Review, "comment should not be modified")
}

// --- Keybinding: x / delete (delete comment) ---

func TestXOnLineWithCommentRemovesItFromUserComments(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 10, Review: "fix this"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})
	resultModel := result.(model)

	assert.Empty(t, resultModel.userComments)
}

func TestXOnLineWithCommentClearsCommentIndexEntry(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 10, Review: "fix this"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})
	resultModel := result.(model)

	assert.Empty(t, resultModel.commentIndex)
}

func TestDeleteKeyBehavesIdenticallyToX(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 10, Review: "fix this"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyDelete})
	resultModel := result.(model)

	assert.Empty(t, resultModel.userComments)
}

func TestXOnLineWithoutCommentDoesNotChangeUserComments(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})
	resultModel := result.(model)

	assert.Empty(t, resultModel.userComments)
}

func TestXOnLineWithoutCommentReturnsNilCommand(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 1
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	_, cmd := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})

	assert.Nil(t, cmd)
}

func TestXOnFileHeaderRowDoesNothing(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 1, Marker: &marker},
		layout.FileHeaderRow{Path: "other.go"},
		layout.LineRow{FilePath: "other.go", LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	// Place cursor on folded header so it's navigable
	m.fileIndex.FoldState["other.go"] = true
	m.refreshIndices()
	m.nav.Cursor = 2
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "keep me"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})
	resultModel := result.(model)

	assert.Len(t, resultModel.userComments, 1, "comment should not be removed")
}

func TestXOnSeparatorRowDoesNothing(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{FilePath: "file.go", LineNumber: 1, Marker: &marker},
		layout.SeparatorRow{},
		layout.LineRow{FilePath: "file.go", LineNumber: 10, Marker: &marker},
	}
	m := testModel(th, rows)
	m.nav.Cursor = 2
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "keep me"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")

	result, _ := m.updateNormal(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'x'}})
	resultModel := result.(model)

	assert.Len(t, resultModel.userComments, 1, "comment should not be removed")
}

// --- Help screen ---

func TestHelpScreenShowsDeleteComment(t *testing.T) {
	th := loadTestTheme(t)
	m := testModel(th, []layout.Row{})
	m.showHelp = true

	output := m.View()

	assert.Contains(t, output, "x")
	assert.Contains(t, output, "Delete comment")
}

func TestHelpScreenShowsCtrlS(t *testing.T) {
	th := loadTestTheme(t)
	m := testModel(th, []layout.Row{})
	m.showHelp = true

	output := m.View()

	assert.Contains(t, output, "ctrl+s")
	assert.Contains(t, output, "Auto-commit all")
}

// --- GitIndexChangedMsg: stale comment clearing ---

func TestGitIndexChangedMsgRemovesStaleComments(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")
	m.resolveHead = func(_ string) (string, error) { return "newhead", nil }
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "stale", CommitHash: "oldhead"},
		{Filepath: "/repo/file.go", LineNumber: 2, Review: "fresh", CommitHash: "newhead"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)

	result, _ := m.Update(GitIndexChangedMsg{})
	resultModel := result.(model)

	require.Len(t, resultModel.userComments, 1)
	assert.Equal(t, "fresh", resultModel.userComments[0].Review)
}

func TestGitIndexChangedMsgRemovesCommentsWithEmptyCommitHash(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")
	m.resolveHead = func(_ string) (string, error) { return "abc123", nil }
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "legacy", CommitHash: ""},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)

	result, _ := m.Update(GitIndexChangedMsg{})
	resultModel := result.(model)

	assert.Empty(t, resultModel.userComments)
}

func TestGitIndexChangedMsgPreservesCommentsWhenHeadUnchanged(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")
	m.resolveHead = func(_ string) (string, error) { return "samehead", nil }
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "keep me", CommitHash: "samehead"},
		{Filepath: "/repo/file.go", LineNumber: 2, Review: "keep me too", CommitHash: "samehead"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)

	result, _ := m.Update(GitIndexChangedMsg{})
	resultModel := result.(model)

	assert.Len(t, resultModel.userComments, 2)
}

func TestGitIndexChangedMsgRebuildCommentIndexAfterClearing(t *testing.T) {
	th := loadTestTheme(t)
	marker := diff.MarkerAdded
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "file.go"},
		layout.LineRow{LineNumber: 1, Marker: &marker},
	}
	m := testModel(th, rows)
	m.commentsPath = filepath.Join(t.TempDir(), "comments.json")
	m.resolveHead = func(_ string) (string, error) { return "newhead", nil }
	m.userComments = []comments.Comment{
		{Filepath: "/repo/file.go", LineNumber: 1, Review: "stale", CommitHash: "oldhead"},
		{Filepath: "/repo/file.go", LineNumber: 2, Review: "fresh", CommitHash: "newhead"},
	}
	m.commentIndex = buildCommentIndex(m.userComments, m.repoRoot)

	result, _ := m.Update(GitIndexChangedMsg{})
	resultModel := result.(model)

	assert.NotContains(t, resultModel.commentIndex, "file.go:1")
	assert.Equal(t, "fresh", resultModel.commentIndex["file.go:2"])
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
	require.NoError(t, os.WriteFile(filepath.Join(dir, "filetypes.json"), []byte(`{}`), 0o644))

	th, err := theme.Load(root)
	require.NoError(t, err)
	return th
}

func testModel(th *theme.Theme, rows []layout.Row) model {
	return testModelWithRoot(th, rows, "/repo")
}

func testModelWithRoot(th *theme.Theme, rows []layout.Row, repoRoot string) model {
	fileIndex := findFileHeaders(rows, navigation.FileIndex{})
	visible := navigation.VisibleIndices(len(rows), fileIndex)
	vc := navigation.ViewContext{
		Navigable: navigableFromVisible(rows, visible, fileIndex.FoldState),
		Visible:   visible,
		Headers:   fileIndex.Headers,
	}
	return model{
		theme:            th,
		rows:             rows,
		highlighted:      map[string][]highlight.StyledLine{},
		rawLines:         map[string][]string{},
		repoRoot:         repoRoot,
		fileIndex:        fileIndex,
		viewContext:      vc,
		commentIndex:    map[string]string{},
		flashLines:      map[string]bool{},
		lineNumberWidth: render.MaxLineNumberWidth(rows),
		nav: navigation.State{
			RowCount:       len(rows),
			ViewportHeight: 40,
		},
	}
}
