package summary

import (
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/stretchr/testify/assert"
)

func testTheme() Theme {
	return Theme{
		FileIcon:     "",
		CreatedColor: lipgloss.Color("2"),
		DeletedColor: lipgloss.Color("1"),
	}
}

// stripAnsi removes ANSI escape sequences to extract the raw text.
func stripAnsi(input string) string {
	result := []byte{}
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

// --- Content ---

func TestShowsFileIconFollowedByTotalCount(t *testing.T) {
	theme := testTheme()
	result := Render(5, 0, 0, theme)
	raw := stripAnsi(result)
	assert.Contains(t, raw, " 5")
}

func TestShowsCreatedCountWithGreenCheckWhenCreatedGreaterThanZero(t *testing.T) {
	theme := testTheme()
	result := Render(3, 2, 0, theme)
	raw := stripAnsi(result)
	assert.Contains(t, raw, "2 ✚")
}

func TestShowsDeletedCountWithRedCrossWhenDeletedGreaterThanZero(t *testing.T) {
	theme := testTheme()
	result := Render(3, 0, 1, theme)
	raw := stripAnsi(result)
	assert.Contains(t, raw, "1 ✖")
}

func TestOmitsCreatedSectionWhenCreatedIsZero(t *testing.T) {
	theme := testTheme()
	result := Render(3, 0, 1, theme)
	raw := stripAnsi(result)
	assert.NotContains(t, raw, "✚")
}

func TestOmitsDeletedSectionWhenDeletedIsZero(t *testing.T) {
	theme := testTheme()
	result := Render(3, 2, 0, theme)
	raw := stripAnsi(result)
	assert.NotContains(t, raw, "✖")
}

func TestShowsBothCreatedAndDeletedWhenBothGreaterThanZero(t *testing.T) {
	theme := testTheme()
	result := Render(5, 2, 1, theme)
	raw := stripAnsi(result)
	assert.Contains(t, raw, "2 ✚")
	assert.Contains(t, raw, "1 ✖")
}

func TestReturnsEmptyStringWhenTotalIsZero(t *testing.T) {
	theme := testTheme()
	result := Render(0, 0, 0, theme)
	assert.Equal(t, "", result)
}
