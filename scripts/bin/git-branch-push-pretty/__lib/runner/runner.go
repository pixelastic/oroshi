package runner

import (
	"bufio"
	"io"
	"strings"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/parser"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/tui"
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

// scanCRLF splits input on both \r and \n for real-time progress updates.
func scanCRLF(data []byte, atEOF bool) (advance int, token []byte, err error) {
	if atEOF && len(data) == 0 {
		return 0, nil, nil
	}
	for i, b := range data {
		if b == '\r' || b == '\n' {
			return i + 1, data[:i], nil
		}
	}
	if atEOF {
		return len(data), data, nil
	}
	return 0, nil, nil
}

// StreamStderr reads from a reader, splits on \r and \n, parses each segment,
// and sends resulting TUI messages via the send function.
func StreamStderr(reader io.Reader, send func(tea.Msg)) {
	scanner := bufio.NewScanner(reader)
	scanner.Split(scanCRLF)
	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}
		event := parser.ParseLine(line)
		msg := EventToMsg(event)
		if msg != nil {
			send(msg)
		}
	}
}
