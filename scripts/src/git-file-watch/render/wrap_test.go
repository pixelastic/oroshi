package render

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

const (
	ansiRed   = "\x1b[31m"
	ansiReset = "\x1b[0m"
)

// --- WrapLine ---

func TestWrapLineWrapsLongStyledLineAtWordBoundary(t *testing.T) {
	styled := ansiRed + "hello world this is a long line" + ansiReset

	result := WrapLine(styled, 15)

	assert.Greater(t, len(result), 1)
	assert.Contains(t, result[0], "hello")
}

func TestWrapLinePreservesAnsiEscapesAcrossWrappedSegments(t *testing.T) {
	styled := ansiRed + "hello world this is long" + ansiReset

	result := WrapLine(styled, 12)

	for _, segment := range result {
		assert.Contains(t, segment, "\x1b[", "segment should contain ANSI escapes")
	}
}

func TestWrapLineReturnsSingleElementForShortLine(t *testing.T) {
	styled := ansiRed + "short" + ansiReset

	result := WrapLine(styled, 80)

	assert.Len(t, result, 1)
	assert.Contains(t, result[0], "short")
}

func TestWrapLineHardWrapsSingleWordWiderThanWidth(t *testing.T) {
	styled := ansiRed + "abcdefghijklmnop" + ansiReset

	result := WrapLine(styled, 5)

	assert.Greater(t, len(result), 1)
}

func TestWrapLineReturnsSingleEmptyStringForEmptyInput(t *testing.T) {
	result := WrapLine("", 80)

	assert.Equal(t, []string{""}, result)
}

func TestWrapLineHandlesLineExactlyEqualToWidth(t *testing.T) {
	styled := ansiRed + "hello" + ansiReset

	result := WrapLine(styled, 5)

	assert.Len(t, result, 1)
}

// --- WrapLineCount ---

func TestWrapLineCountReturnsOneForShortLine(t *testing.T) {
	result := WrapLineCount("short", 80)

	assert.Equal(t, 1, result)
}

func TestWrapLineCountReturnsCorrectCountForLongLine(t *testing.T) {
	long := "hello world this is a very long line that should wrap"

	result := WrapLineCount(long, 15)

	assert.Greater(t, result, 1)
}

func TestWrapLineCountReturnsOneForEmptyString(t *testing.T) {
	result := WrapLineCount("", 80)

	assert.Equal(t, 1, result)
}

func TestWrapLineCountReturnsCorrectCountForLineWithOnlySpaces(t *testing.T) {
	result := WrapLineCount("          ", 5)

	assert.GreaterOrEqual(t, result, 1)
}

func TestWrapLineCountHandlesWidthOfOne(t *testing.T) {
	result := WrapLineCount("abc", 1)

	assert.Equal(t, 3, result)
}

// --- Scaffolding: agreement ---

func TestWrapLineCountAgreesWithWrapLineForRawText(t *testing.T) {
	cases := []struct {
		name  string
		text  string
		width int
	}{
		{"short line", "hello", 80},
		{"long line", "hello world this is a long line of text", 15},
		{"empty", "", 80},
		{"single word hard wrap", "abcdefghijklmnop", 5},
		{"exact width", "hello", 5},
		{"spaces only", strings.Repeat(" ", 10), 5},
		{"width of 1", "abc", 1},
	}
	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			wrapCount := len(WrapLine(tt.text, tt.width))
			countResult := WrapLineCount(tt.text, tt.width)
			assert.Equal(t, wrapCount, countResult, "WrapLineCount should agree with len(WrapLine)")
		})
	}
}
