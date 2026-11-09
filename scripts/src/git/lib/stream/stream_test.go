package stream

import (
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// collect reads input and returns every message sent, using handleLine as the
// line handler.
func collect(input string, handleLine func(string) tea.Msg) []tea.Msg {
	var messages []tea.Msg
	Read(strings.NewReader(input), func(msg tea.Msg) { messages = append(messages, msg) }, handleLine)
	return messages
}

func ignoreLine(string) tea.Msg { return nil }

func TestSplitsOnNewlineIntoOneMessagePerLine(t *testing.T) {
	messages := collect("first\nsecond\n", ignoreLine)
	assert.Equal(t, []tea.Msg{
		LineMsg{Line: "first"},
		LineMsg{Line: "second"},
	}, messages)
}

func TestMarksCarriageReturnSegmentAsOverwriting(t *testing.T) {
	messages := collect("50%\r100%\n", ignoreLine)
	assert.Equal(t, []tea.Msg{
		LineMsg{Line: "50%", Overwrite: true},
		LineMsg{Line: "100%"},
	}, messages)
}

func TestFlushesLastSegmentWithoutDelimiter(t *testing.T) {
	messages := collect("first\nlast", ignoreLine)
	assert.Equal(t, []tea.Msg{
		LineMsg{Line: "first"},
		LineMsg{Line: "last"},
	}, messages)
}

func TestIgnoresEmptySegments(t *testing.T) {
	messages := collect("\n\r\nfirst\r\n\n", ignoreLine)
	assert.Equal(t, []tea.Msg{
		LineMsg{Line: "first", Overwrite: true},
	}, messages)
}

func TestSendsHandlerMessageAfterLineMessage(t *testing.T) {
	type parsed struct{ line string }
	handleLine := func(line string) tea.Msg { return parsed{line} }
	messages := collect("first\n", handleLine)
	require.Len(t, messages, 2)
	assert.Equal(t, LineMsg{Line: "first"}, messages[0])
	assert.Equal(t, parsed{"first"}, messages[1])
}

func TestSkipsNilHandlerMessage(t *testing.T) {
	messages := collect("first\n", ignoreLine)
	assert.Len(t, messages, 1)
}

func TestHandlesFlushedLastSegment(t *testing.T) {
	var handled []string
	handleLine := func(line string) tea.Msg {
		handled = append(handled, line)
		return nil
	}
	collect("first\nlast", handleLine)
	assert.Equal(t, []string{"first", "last"}, handled)
}
