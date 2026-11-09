// Package stream splits a process output stream into line messages.
package stream

import (
	"bufio"
	"io"

	tea "github.com/charmbracelet/bubbletea"
)

// LineMsg carries one raw line of the stream.
// Overwrite replaces the last line (simulates \r carriage return behavior).
type LineMsg struct {
	Line      string
	Overwrite bool
}

// Read reads from a reader, splits on \r and \n, and sends a LineMsg per
// non-empty segment via the send function.
// Segments terminated by \r are flagged Overwrite to simulate terminal
// carriage return behavior (in-place progress updates).
// After each LineMsg, handleLine parses the line and its message is sent too,
// unless it returns nil.
func Read(reader io.Reader, send func(tea.Msg), handleLine func(line string) tea.Msg) {
	br := bufio.NewReader(reader)
	var current []byte
	for {
		b, err := br.ReadByte()
		if err != nil {
			// Flush remaining data
			if len(current) > 0 {
				emit(string(current), false, send, handleLine)
			}
			return
		}
		if b != '\r' && b != '\n' {
			current = append(current, b)
			continue
		}
		// Hit a delimiter — emit the line
		if len(current) == 0 {
			continue
		}
		line := string(current)
		current = current[:0]
		emit(line, b == '\r', send, handleLine)
	}
}

func emit(line string, overwrite bool, send func(tea.Msg), handleLine func(string) tea.Msg) {
	send(LineMsg{Line: line, Overwrite: overwrite})
	if msg := handleLine(line); msg != nil {
		send(msg)
	}
}
