package runner

import (
	"bufio"
	"io"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git-branch-push-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git-branch-push-pretty/tui"
)

// ParseArgs extracts branch/remote from user args, resolving defaults via runner.
// Returns: branch name, remote name, full args for git-branch-push (with --progress), error.
func ParseArgs(args []string, runner func(string, ...string) (string, error)) (string, string, []string, error) {
	var positional []string
	var flags []string

	for i := 0; i < len(args); i++ {
		if strings.HasPrefix(args[i], "-") {
			flags = append(flags, args[i])
			// --repo takes a value argument
			if args[i] == "--repo" && i+1 < len(args) {
				i++
				flags = append(flags, args[i])
			}
		} else {
			positional = append(positional, args[i])
		}
	}

	branch := ""
	if len(positional) > 0 {
		branch = positional[0]
	}
	remote := ""
	if len(positional) > 1 {
		remote = positional[1]
	}

	if branch == "" {
		output, err := runner("bin-zsh", "git-branch-current")
		if err != nil {
			return "", "", nil, err
		}
		branch = strings.TrimSpace(output)
	}

	if remote == "" {
		output, err := runner("bin-zsh", "git-remote-current")
		if err != nil {
			return "", "", nil, err
		}
		remote = strings.TrimSpace(output)
	}

	pushArgs := append(args, "--progress")

	return branch, remote, pushArgs, nil
}

// EventToMsg converts a parser Event to a tui message, or nil for ignored events.
func EventToMsg(event parser.Event) tea.Msg {
	switch event.Type {
	case parser.Progress:
		return tui.ProgressMsg{Phase: event.Phase, Percentage: event.Percentage}
	case parser.Error:
		return tui.ErrorMsg{Raw: event.Raw}
	case parser.UpToDate:
		return tui.UpToDateMsg{}
	case parser.RefUpdate:
		// Ref update with commit hashes
		if event.FromRef != "" && event.ToRef != "" {
			return tui.RefUpdateMsg{FromRef: event.FromRef, ToRef: event.ToRef}
		}
		// Destination line (To <url>) — not needed by TUI
		return nil
	case parser.RemoteMessage:
		return tui.RemoteMessageMsg{Text: event.Raw}
	default:
		return nil
	}
}

// StreamStderr reads from a reader, splits on \r and \n, parses each segment,
// and sends resulting TUI messages via the send function.
// Lines terminated by \r send RawLineMsg with Overwrite=true to simulate
// terminal carriage return behavior (in-place progress updates).
func StreamStderr(reader io.Reader, send func(tea.Msg)) {
	br := bufio.NewReader(reader)
	var current []byte
	for {
		b, err := br.ReadByte()
		if err != nil {
			// Flush remaining data
			if len(current) > 0 {
				line := string(current)
				send(tui.RawLineMsg{Line: line})
				event := parser.ParseLine(line)
				if msg := EventToMsg(event); msg != nil {
					send(msg)
				}
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
		send(tui.RawLineMsg{Line: line, Overwrite: b == '\r'})
		event := parser.ParseLine(line)
		if msg := EventToMsg(event); msg != nil {
			send(msg)
		}
	}
}
