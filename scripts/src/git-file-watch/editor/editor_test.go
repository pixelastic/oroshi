package editor

import (
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/layout"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Command construction ---

func TestBuildsNvimCommandForLineRow(t *testing.T) {
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "src/main.go"},
		layout.LineRow{LineNumber: 5},
	}

	cmd := NvimCommand(rows, 1, "/repo")

	require.NotNil(t, cmd)
	assert.Equal(t, []string{"nvim", "+5", "/repo/src/main.go"}, cmd.Args)
}

func TestBuildsNvimCommandForFileHeader(t *testing.T) {
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "src/main.go"},
		layout.LineRow{LineNumber: 5},
	}

	cmd := NvimCommand(rows, 0, "/repo")

	require.NotNil(t, cmd)
	assert.Equal(t, []string{"nvim", "+1", "/repo/src/main.go"}, cmd.Args)
}

func TestBuildsNvimCommandForSeparatorRow(t *testing.T) {
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "src/main.go"},
		layout.LineRow{LineNumber: 5},
		layout.SeparatorRow{},
		layout.LineRow{LineNumber: 20},
	}

	cmd := NvimCommand(rows, 2, "/repo")

	require.NotNil(t, cmd)
	assert.Equal(t, []string{"nvim", "+1", "/repo/src/main.go"}, cmd.Args)
}

func TestUsesAbsoluteFilePath(t *testing.T) {
	rows := []layout.Row{
		layout.FileHeaderRow{Path: "deep/nested/file.go"},
		layout.LineRow{LineNumber: 10},
	}

	cmd := NvimCommand(rows, 1, "/home/user/repo")

	require.NotNil(t, cmd)
	assert.Equal(t, "/home/user/repo/deep/nested/file.go", cmd.Args[2])
}
