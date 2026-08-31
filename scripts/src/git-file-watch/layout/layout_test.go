package layout

import (
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-file-watch/diff"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func fileDiffWithPath(path string) diff.FileDiff {
	return diff.FileDiff{Path: path}
}

// --- Context expansion ---

func TestExpandsMarkedLineToThreeLinesBeforeAndAfter(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	markers := map[int]diff.Marker{10: diff.MarkerAdded}

	rows := Build(fd, markers, 20)

	// Header + lines 7..13 = 8 rows
	require.Len(t, rows, 8)

	// First row is header
	_, isHeader := rows[0].(FileHeaderRow)
	assert.True(t, isHeader)

	// Lines 7 through 13
	for i, expectedLine := range []int{7, 8, 9, 10, 11, 12, 13} {
		line, ok := rows[i+1].(LineRow)
		require.True(t, ok, "row %d should be LineRow", i+1)
		assert.Equal(t, expectedLine, line.LineNumber)
	}
}

func TestClampsContextToFileBoundaries(t *testing.T) {
	fd := fileDiffWithPath("file.go")

	t.Run("clamps to line 1", func(t *testing.T) {
		markers := map[int]diff.Marker{2: diff.MarkerAdded}
		rows := Build(fd, markers, 20)

		// Header + lines 1..5 = 6 rows
		require.Len(t, rows, 6)
		firstLine := rows[1].(LineRow)
		assert.Equal(t, 1, firstLine.LineNumber)
	})

	t.Run("clamps to totalLines", func(t *testing.T) {
		markers := map[int]diff.Marker{19: diff.MarkerAdded}
		rows := Build(fd, markers, 20)

		// Header + lines 16..20 = 6 rows
		require.Len(t, rows, 6)
		lastLine := rows[len(rows)-1].(LineRow)
		assert.Equal(t, 20, lastLine.LineNumber)
	})
}

func TestMergesOverlappingContextRangesIntoOneBlock(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	// Lines 10 and 14: ranges [7..13] and [11..17] overlap → merged to [7..17]
	markers := map[int]diff.Marker{
		10: diff.MarkerAdded,
		14: diff.MarkerModified,
	}

	rows := Build(fd, markers, 30)

	// Header + lines 7..17 = 12 rows, no separator
	require.Len(t, rows, 12)
	for _, row := range rows[1:] {
		_, isSep := row.(SeparatorRow)
		assert.False(t, isSep, "should not contain separators in merged range")
	}
}

// --- Separator insertion ---

func TestInsertsSeparatorBetweenNonContiguousBlocks(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	// Lines 5 and 20: ranges [2..8] and [17..23] — gap between them
	markers := map[int]diff.Marker{
		5:  diff.MarkerAdded,
		20: diff.MarkerAdded,
	}

	rows := Build(fd, markers, 30)

	separatorCount := 0
	for _, row := range rows {
		if _, ok := row.(SeparatorRow); ok {
			separatorCount++
		}
	}
	assert.Equal(t, 1, separatorCount)
}

func TestDoesNotInsertSeparatorBetweenAdjacentBlocks(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	// Lines 10 and 17: ranges [7..13] and [14..20] — adjacent (13 next to 14)
	markers := map[int]diff.Marker{
		10: diff.MarkerAdded,
		17: diff.MarkerAdded,
	}

	rows := Build(fd, markers, 30)

	for _, row := range rows {
		_, isSep := row.(SeparatorRow)
		assert.False(t, isSep, "should not insert separator between adjacent blocks")
	}
}

func TestDoesNotInsertSeparatorAtFileStart(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	markers := map[int]diff.Marker{5: diff.MarkerAdded}

	rows := Build(fd, markers, 20)

	require.True(t, len(rows) > 1)
	_, isHeader := rows[0].(FileHeaderRow)
	assert.True(t, isHeader, "first row should be header, not separator")
	_, isSep := rows[1].(SeparatorRow)
	assert.False(t, isSep, "second row should not be separator")
}

// --- Row emission ---

func TestEmitsFileHeaderAsFirstRow(t *testing.T) {
	fd := fileDiffWithPath("src/main.go")
	markers := map[int]diff.Marker{5: diff.MarkerAdded}

	rows := Build(fd, markers, 20)

	require.True(t, len(rows) > 0)
	header, ok := rows[0].(FileHeaderRow)
	require.True(t, ok)
	assert.Equal(t, "src/main.go", header.Path)
}

func TestEmitsLineRowsWithCorrectLineNumbers(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	markers := map[int]diff.Marker{5: diff.MarkerAdded}

	rows := Build(fd, markers, 20)

	lineNumbers := []int{}
	for _, row := range rows {
		if line, ok := row.(LineRow); ok {
			lineNumbers = append(lineNumbers, line.LineNumber)
		}
	}
	assert.Equal(t, []int{2, 3, 4, 5, 6, 7, 8}, lineNumbers)
}

func TestEmitsNilMarkerForContextLines(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	markers := map[int]diff.Marker{10: diff.MarkerAdded}

	rows := Build(fd, markers, 20)

	for _, row := range rows {
		line, ok := row.(LineRow)
		if !ok {
			continue
		}
		if line.LineNumber == 10 {
			continue
		}
		assert.Nil(t, line.Marker, "context line %d should have nil marker", line.LineNumber)
	}
}

func TestEmitsCorrectMarkerForClassifiedLines(t *testing.T) {
	fd := fileDiffWithPath("file.go")
	added := diff.MarkerAdded
	modified := diff.MarkerModified
	markers := map[int]diff.Marker{
		10: diff.MarkerAdded,
		12: diff.MarkerModified,
	}

	rows := Build(fd, markers, 20)

	for _, row := range rows {
		line, ok := row.(LineRow)
		if !ok {
			continue
		}
		switch line.LineNumber {
		case 10:
			require.NotNil(t, line.Marker)
			assert.Equal(t, added, *line.Marker)
		case 12:
			require.NotNil(t, line.Marker)
			assert.Equal(t, modified, *line.Marker)
		}
	}
}
