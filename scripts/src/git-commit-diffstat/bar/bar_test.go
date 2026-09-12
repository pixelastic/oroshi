package bar

import (
	"testing"

	"github.com/charmbracelet/lipgloss"
	"github.com/pixelastic/oroshi/scripts/src/git-commit-diffstat/diff"
	"github.com/stretchr/testify/assert"
)

func testColors() Colors {
	return Colors{
		Added:    lipgloss.Color("2"),
		Removed:  lipgloss.Color("1"),
		Modified: lipgloss.Color("5"),
	}
}

// stripAnsi removes ANSI escape sequences to extract the raw bar characters.
func stripAnsi(input string) string {
	result := []byte{}
	i := 0
	for i < len(input) {
		if input[i] == '\x1b' {
			// Skip until 'm'
			for i < len(input) && input[i] != 'm' {
				i++
			}
			i++ // skip the 'm'
			continue
		}
		result = append(result, input[i])
		i++
	}
	return string(result)
}

// --- Log scale ---

func TestLogScale(t *testing.T) {
	colors := testColors()

	tests := []struct {
		name     string
		lines    int
		expected string
	}{
		{"1 line maps to level 1", 1, "▁"},
		{"10 lines maps to level 2", 10, "▂"},
		{"30 lines maps to level 3", 30, "▃"},
		{"100 lines maps to level 4", 100, "▄"},
		{"300 lines maps to level 5", 300, "▅"},
		{"1000 lines maps to level 6", 1000, "▆"},
		{"5000 lines caps at level 6", 5000, "▆"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Use additions-only so we get a single green bar
			result := Render(tt.lines, 0, diff.Added, false, colors)
			raw := stripAnsi(result)
			assert.Equal(t, tt.expected, raw)
		})
	}
}

func TestNeverProducesTooTallBars(t *testing.T) {
	colors := testColors()
	// Test a range of large values — max bar is ▆, never ▇ or █
	for _, lines := range []int{1, 100, 1000, 10000, 100000} {
		result := Render(lines, 0, diff.Added, false, colors)
		raw := stripAnsi(result)
		assert.NotContains(t, raw, "▇")
		assert.NotContains(t, raw, "█")
	}
}

// --- Color rules ---

func TestEqualAdditionsAndDeletionsRendersSinglePurpleBar(t *testing.T) {
	colors := testColors()
	result := Render(50, 50, diff.Modified, false, colors)
	raw := stripAnsi(result)
	// Single bar character (purple), not two
	assert.Len(t, []rune(raw), 1)
}

func TestMoreAdditionsThanDeletionsRendersGreenThenRedBar(t *testing.T) {
	colors := testColors()
	result := Render(100, 10, diff.Modified, false, colors)
	raw := stripAnsi(result)
	runes := []rune(raw)
	// Two bar characters: green then red
	assert.Len(t, runes, 2)
}

func TestMoreDeletionsThanAdditionsRendersGreenThenRedBar(t *testing.T) {
	colors := testColors()
	result := Render(10, 100, diff.Modified, false, colors)
	raw := stripAnsi(result)
	runes := []rune(raw)
	// Two bar characters: green then red
	assert.Len(t, runes, 2)
}

func TestZeroDeletionsRendersGreenBarOnly(t *testing.T) {
	colors := testColors()
	result := Render(50, 0, diff.Added, false, colors)
	raw := stripAnsi(result)
	runes := []rune(raw)
	assert.Len(t, runes, 1)
}

func TestZeroAdditionsRendersRedBarOnly(t *testing.T) {
	colors := testColors()
	result := Render(0, 50, diff.Deleted, false, colors)
	raw := stripAnsi(result)
	runes := []rune(raw)
	assert.Len(t, runes, 1)
}

// --- Special cases ---

func TestBinaryCreatedRendersGreenBar(t *testing.T) {
	colors := testColors()
	result := Render(0, 0, diff.Added, true, colors)
	raw := stripAnsi(result)
	assert.Equal(t, "▆", raw)
}

func TestBinaryDeletedRendersRedBar(t *testing.T) {
	colors := testColors()
	result := Render(0, 0, diff.Deleted, true, colors)
	raw := stripAnsi(result)
	assert.Equal(t, "▆", raw)
}

func TestBinaryModifiedRendersPurpleBar(t *testing.T) {
	colors := testColors()
	result := Render(0, 0, diff.Modified, true, colors)
	raw := stripAnsi(result)
	assert.Equal(t, "▄", raw)
}

func TestZeroAdditionsAndZeroDeletionsRendersEmptyString(t *testing.T) {
	colors := testColors()
	result := Render(0, 0, diff.Modified, false, colors)
	assert.Equal(t, "", result)
}
