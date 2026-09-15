package tree

import (
	"os"
	"strings"
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMain(m *testing.M) {
	if err := os.Setenv("CLICOLOR_FORCE", "1"); err != nil {
		panic(err)
	}
	os.Exit(m.Run())
}

// mockTheme implements ThemeResolver with predictable colors.
type mockTheme struct {
	filetypeColors map[string]lipgloss.Color
	namedColors    map[string]lipgloss.Color
}

func (m *mockTheme) FiletypeColor(filename string) lipgloss.Color {
	if c, ok := m.filetypeColors[filename]; ok {
		return c
	}
	return lipgloss.Color("")
}

func (m *mockTheme) Lipgloss(name string) lipgloss.Color {
	if c, ok := m.namedColors[name]; ok {
		return c
	}
	return lipgloss.Color("")
}

func testTheme() *mockTheme {
	return &mockTheme{
		filetypeColors: map[string]lipgloss.Color{
			"main.go":    lipgloss.Color("4"),
			"README.md":  lipgloss.Color("3"),
			"index.js":   lipgloss.Color("3"),
			"style.css":  lipgloss.Color("5"),
			"app.go":     lipgloss.Color("4"),
			"util.go":    lipgloss.Color("4"),
			"config.yml": lipgloss.Color("6"),
			"a.go":       lipgloss.Color("4"),
			"b.go":       lipgloss.Color("4"),
			"c.txt":      lipgloss.Color("7"),
			"old.go":     lipgloss.Color("4"),
			"new.go":     lipgloss.Color("4"),
		},
		namedColors: map[string]lipgloss.Color{
			"directory":   lipgloss.Color("6"),
			"gray":        lipgloss.Color("8"),
			"git-added":   lipgloss.Color("2"),
			"git-removed": lipgloss.Color("1"),
		},
	}
}

// noopBar returns a fixed bar for every file, to test bar placement.
func noopBar(_ diff.FileChange) string {
	return "▃"
}

// emptyBar returns no bar, to isolate tree structure tests.
func emptyBar(_ diff.FileChange) string {
	return ""
}

// stripAnsi removes ANSI escape sequences.
func stripAnsi(input string) string {
	var result []byte
	i := 0
	for i < len(input) {
		if input[i] == '\x1b' {
			for i < len(input) && input[i] != 'm' {
				i++
			}
			i++
			continue
		}
		result = append(result, input[i])
		i++
	}
	return string(result)
}

// contentBar returns a bar only when there are additions or deletions.
func contentBar(change diff.FileChange) string {
	if change.Additions == 0 && change.Deletions == 0 {
		return ""
	}
	return "▃"
}

// findLine returns the first output line whose stripped text contains substring.
func findLine(output, substring string) string {
	for _, line := range strings.Split(strings.TrimRight(output, "\n"), "\n") {
		if strings.Contains(stripAnsi(line), substring) {
			return line
		}
	}
	return ""
}

// findPlainLine returns the first stripped line containing substring.
func findPlainLine(output, substring string) string {
	plain := stripAnsi(output)
	for _, line := range strings.Split(strings.TrimRight(plain, "\n"), "\n") {
		if strings.Contains(line, substring) {
			return line
		}
	}
	return ""
}

// hasStrikethrough checks if ANSI output contains strikethrough styling (SGR 9).
func hasStrikethrough(s string) bool {
	return strings.Contains(s, "\x1b[9m") ||
		strings.Contains(s, "\x1b[9;") ||
		strings.Contains(s, ";9m") ||
		strings.Contains(s, ";9;")
}

func change(path string) diff.FileChange {
	return diff.FileChange{Path: path, Additions: 10, Deletions: 5, Status: diff.Modified}
}

func addedChange(path string) diff.FileChange {
	return diff.FileChange{Path: path, Additions: 10, Status: diff.Added}
}

func deletedChange(path string) diff.FileChange {
	return diff.FileChange{Path: path, Deletions: 10, Status: diff.Deleted}
}

func renamedChange(oldPath, newPath string, additions, deletions int) diff.FileChange {
	return diff.FileChange{
		Path:      newPath,
		OldPath:   oldPath,
		Status:    diff.Renamed,
		Additions: additions,
		Deletions: deletions,
	}
}

// --- Tree building ---

func TestSingleFileAtRootCreatesFlatTree(t *testing.T) {
	changes := []diff.FileChange{change("main.go")}
	tree := Build(changes)
	assert.Len(t, tree.Roots, 1)
	assert.Equal(t, "main.go", tree.Roots[0].Name)
	assert.False(t, tree.Roots[0].IsDir)
}

func TestFilesInSameDirectoryGroupedUnderDirectoryNode(t *testing.T) {
	changes := []diff.FileChange{
		change("src/app.go"),
		change("src/util.go"),
	}
	tree := Build(changes)
	assert.Len(t, tree.Roots, 1)
	assert.Equal(t, "src", tree.Roots[0].Name)
	assert.True(t, tree.Roots[0].IsDir)
	assert.Len(t, tree.Roots[0].Children, 2)
}

func TestNestedDirectoriesCreateNestedTreeNodes(t *testing.T) {
	changes := []diff.FileChange{change("src/pkg/main.go")}
	tree := Build(changes)
	assert.Len(t, tree.Roots, 1)
	assert.Equal(t, "src", tree.Roots[0].Name)
	assert.True(t, tree.Roots[0].IsDir)
	assert.Len(t, tree.Roots[0].Children, 1)
	assert.Equal(t, "pkg", tree.Roots[0].Children[0].Name)
	assert.True(t, tree.Roots[0].Children[0].IsDir)
	assert.Len(t, tree.Roots[0].Children[0].Children, 1)
	assert.Equal(t, "main.go", tree.Roots[0].Children[0].Children[0].Name)
}

func TestFilesSortedAlphabeticallyWithinDirectory(t *testing.T) {
	changes := []diff.FileChange{
		change("src/c.txt"),
		change("src/a.go"),
		change("src/b.go"),
	}
	tree := Build(changes)
	children := tree.Roots[0].Children
	assert.Equal(t, "a.go", children[0].Name)
	assert.Equal(t, "b.go", children[1].Name)
	assert.Equal(t, "c.txt", children[2].Name)
}

func TestDirectoriesSortedAlphabeticallyWithinParent(t *testing.T) {
	changes := []diff.FileChange{
		change("zoo/main.go"),
		change("alpha/main.go"),
		change("mid/main.go"),
	}
	tree := Build(changes)
	assert.Equal(t, "alpha", tree.Roots[0].Name)
	assert.Equal(t, "mid", tree.Roots[1].Name)
	assert.Equal(t, "zoo", tree.Roots[2].Name)
}

func TestDirectoriesAppearBeforeFilesAtSameLevel(t *testing.T) {
	changes := []diff.FileChange{
		change("main.go"),
		change("src/app.go"),
		change("README.md"),
	}
	tree := Build(changes)
	// Directories first, then files
	assert.True(t, tree.Roots[0].IsDir)
	assert.Equal(t, "src", tree.Roots[0].Name)
	assert.False(t, tree.Roots[1].IsDir)
	assert.False(t, tree.Roots[2].IsDir)
}

// --- Tree rendering ---

func TestRootLevelFileHasNoConnectorPrefix(t *testing.T) {
	changes := []diff.FileChange{change("main.go"), change("README.md")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	stripped := stripAnsi(lines[0])
	assert.False(t, strings.HasPrefix(stripped, "├─"), "root items should not have connector")
	assert.False(t, strings.HasPrefix(stripped, "└─"), "root items should not have connector")
}

func TestNestedFileHasCorrectIndentation(t *testing.T) {
	changes := []diff.FileChange{
		change("src/pkg/main.go"),
		change("src/other.go"),
	}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	plain := stripAnsi(output)
	// The nested file should have │ prefix for sibling directory
	assert.Contains(t, plain, "│ ")
}

func TestLastItemAtNestedLevelUsesEndConnector(t *testing.T) {
	changes := []diff.FileChange{change("src/a.go"), change("src/b.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	lastLine := stripAnsi(lines[len(lines)-1])
	assert.Contains(t, lastLine, "└─ ")
}

func TestDirectoryNamesUseDirectoryColor(t *testing.T) {
	changes := []diff.FileChange{change("src/main.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	// First line is the directory — should contain ANSI color 6 (directory color)
	assert.Contains(t, lines[0], "\x1b[36m") // color 6 = cyan
}

func TestFileNamesUseFiletypeColor(t *testing.T) {
	changes := []diff.FileChange{change("main.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	// Should contain ANSI color 4 (blue, our mock .go color)
	assert.Contains(t, output, "\x1b[34m") // color 4 = blue
}

func TestFiletypeColorReceivesFullPathNotJustName(t *testing.T) {
	changes := []diff.FileChange{change("tools/term/zsh/config/functions/autoload/todo-add")}
	tree := Build(changes)
	// Mock maps the full path to a color — if tree passes just "todo-add", no color is found
	theme := &mockTheme{
		filetypeColors: map[string]lipgloss.Color{
			"tools/term/zsh/config/functions/autoload/todo-add": lipgloss.Color("5"),
		},
		namedColors: map[string]lipgloss.Color{
			"directory": lipgloss.Color("6"),
			"gray":      lipgloss.Color("8"),
		},
	}
	output := Render(tree, theme, emptyBar)
	line := findLine(output, "todo-add")
	require.NotEmpty(t, line)
	// color 5 = magenta
	assert.Contains(t, line, "\x1b[35m")
}

func TestBarAppearsAfterFilenameWithSpaceSeparator(t *testing.T) {
	changes := []diff.FileChange{change("main.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "main.go ▃")
}

func TestConnectorsAreGray(t *testing.T) {
	changes := []diff.FileChange{change("src/main.go"), change("src/README.md")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	// Second line is a nested file — connector should be styled with gray (color 8)
	assert.Contains(t, lines[1], "\x1b[90m") // color 8 = bright black / gray
}

// --- Status display: Created files ---

func TestCreatedFileNameUsesFiletypeColor(t *testing.T) {
	changes := []diff.FileChange{addedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	// Should use filetype color (4 = blue for .go), not red
	assert.Contains(t, output, "\x1b[34m")
}

func TestCreatedFileHasBarAfterName(t *testing.T) {
	changes := []diff.FileChange{addedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "main.go ▃")
}

func TestCreatedFileHasGreenStatusSymbolAfterBar(t *testing.T) {
	changes := []diff.FileChange{addedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "▃ ✚")
	// ✚ should be green (git-added = color 2)
	line := findLine(output, "✚")
	assert.Contains(t, line, "\x1b[32m")
}

// --- Status display: Deleted files ---

func TestDeletedFileNameIsRedWithStrikethrough(t *testing.T) {
	changes := []diff.FileChange{deletedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	line := findLine(output, "main.go")
	require.NotEmpty(t, line)
	// Should have red color (git-removed = color 1)
	assert.Contains(t, line, "\x1b[31m")
	// Should have strikethrough (SGR 9)
	assert.True(t, hasStrikethrough(line), "deleted file should have strikethrough")
}

func TestDeletedFileHasBarAfterName(t *testing.T) {
	changes := []diff.FileChange{deletedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "main.go ▃")
}

func TestDeletedFileHasRedStatusSymbolAfterBar(t *testing.T) {
	changes := []diff.FileChange{deletedChange("main.go")}
	tree := Build(changes)
	output := Render(tree, testTheme(), noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "▃ ✖")
	// ✖ should be red (git-removed = color 1)
	line := findLine(output, "✖")
	assert.Contains(t, line, "\x1b[31m")
}

// --- Status display: Renamed files ---

func TestRenameSourceAppearsAtOldPathLocation(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old/app.go", "new/app.go", 0, 0)}
	tree := Build(changes)
	dirNames := []string{}
	for _, root := range tree.Roots {
		dirNames = append(dirNames, root.Name)
	}
	assert.Contains(t, dirNames, "old")
	assert.Contains(t, dirNames, "new")
}

func TestRenameSourceNameIsRedWithStrikethrough(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "new.go", 0, 0)}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	line := findLine(output, "old.go")
	require.NotEmpty(t, line)
	assert.Contains(t, line, "\x1b[31m")
	assert.True(t, hasStrikethrough(line), "rename source should have strikethrough")
}

func TestRenameSourceHasRedArrowAfterName(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "new.go", 0, 0)}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	plain := findPlainLine(output, "old.go")
	require.NotEmpty(t, plain)
	assert.Contains(t, plain, "old.go →")
}

func TestRenameDestinationAppearsAtNewPathLocation(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old/app.go", "new/app.go", 0, 0)}
	tree := Build(changes)
	for _, root := range tree.Roots {
		if root.Name == "new" {
			require.Len(t, root.Children, 1)
			assert.Equal(t, "app.go", root.Children[0].Name)
			return
		}
	}
	t.Fatal("new directory not found in tree")
}

func TestRenameDestinationNameUsesFiletypeColor(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "app.go", 0, 0)}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	line := findLine(output, "app.go")
	require.NotEmpty(t, line)
	// color 4 = blue (.go filetype)
	assert.Contains(t, line, "\x1b[34m")
}

func TestRenameDestinationHasGreenArrowAfterName(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "new.go", 0, 0)}
	tree := Build(changes)
	output := Render(tree, testTheme(), emptyBar)
	plain := findPlainLine(output, "new.go")
	require.NotEmpty(t, plain)
	assert.Contains(t, plain, "new.go ←")
}

func TestRenameDestinationHasBarIfContentChanged(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "new.go", 10, 5)}
	tree := Build(changes)
	output := Render(tree, testTheme(), contentBar)
	plain := findPlainLine(output, "new.go")
	require.NotEmpty(t, plain)
	assert.Contains(t, plain, "← ▃")
}

func TestRenameDestinationHasNoBarIfContentUnchanged(t *testing.T) {
	changes := []diff.FileChange{renamedChange("old.go", "new.go", 0, 0)}
	tree := Build(changes)
	output := Render(tree, testTheme(), contentBar)
	plain := findPlainLine(output, "new.go")
	require.NotEmpty(t, plain)
	assert.NotContains(t, plain, "▃")
}
