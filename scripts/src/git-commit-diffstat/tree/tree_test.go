package tree

import (
	"os"
	"strings"
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
	"github.com/stretchr/testify/assert"
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
		},
		namedColors: map[string]lipgloss.Color{
			"directory": lipgloss.Color("6"),
			"gray":      lipgloss.Color("8"),
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

func change(path string) diff.FileChange {
	return diff.FileChange{Path: path, Additions: 10, Deletions: 5, Status: diff.Modified}
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

func TestRootLevelFileUsesConnector(t *testing.T) {
	changes := []diff.FileChange{change("main.go"), change("README.md")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	stripped := stripAnsi(lines[0])
	assert.True(t, strings.HasPrefix(stripped, "├── "))
}

func TestNestedFileHasCorrectIndentation(t *testing.T) {
	changes := []diff.FileChange{
		change("src/pkg/main.go"),
		change("other.go"),
	}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	plain := stripAnsi(output)
	// The nested file should have │ prefix for the parent directory
	assert.Contains(t, plain, "│   ")
}

func TestLastItemAtEachLevelUsesEndConnector(t *testing.T) {
	changes := []diff.FileChange{change("a.go"), change("b.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	lastLine := stripAnsi(lines[len(lines)-1])
	assert.True(t, strings.HasPrefix(lastLine, "└── "))
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

func TestBarAppearsAfterFilenameWithSpaceSeparator(t *testing.T) {
	changes := []diff.FileChange{change("main.go")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, noopBar)
	plain := stripAnsi(output)
	assert.Contains(t, plain, "main.go ▃")
}

func TestConnectorsAreGray(t *testing.T) {
	changes := []diff.FileChange{change("main.go"), change("README.md")}
	tree := Build(changes)
	theme := testTheme()
	output := Render(tree, theme, emptyBar)
	lines := strings.Split(strings.TrimRight(output, "\n"), "\n")
	// Connector should be styled with gray (color 8)
	assert.Contains(t, lines[0], "\x1b[90m") // color 8 = bright black / gray
}
