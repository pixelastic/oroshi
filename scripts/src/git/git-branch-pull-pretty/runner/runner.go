// Package runner runs git-branch-pull and turns its stderr into TUI messages.
package runner

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os/exec"
	"strconv"
	"strings"
	"sync"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/tui"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/stream"
)

// backgroundGrace is how long to wait for stderr after the command exited,
// because a background process (dependencies update) can keep the pipe open.
const backgroundGrace = 200 * time.Millisecond

// CommandRunner executes a command and returns its stdout.
type CommandRunner func(name string, args ...string) (string, error)

// EventToMsg converts a parser Event to a tui message, or nil for ignored events.
func EventToMsg(event parser.Event) tea.Msg {
	switch event.Type {
	case parser.Progress:
		return progress.PhaseMsg{Phase: event.Phase, Percentage: event.Percentage}
	case parser.Error:
		return progress.ErrorMsg{Raw: event.Raw}
	case parser.BranchUpdate, parser.NewTag:
		return tui.EventMsg{Event: event}
	default:
		return nil
	}
}

// StreamStderr reads from a reader, splits it into lines, parses each line,
// and sends resulting TUI messages via the send function.
func StreamStderr(reader io.Reader, send func(tea.Msg)) {
	stream.Read(reader, send, func(line string) tea.Msg {
		return EventToMsg(parser.ParseLine(line))
	})
}

// CommitCounts returns the number of new commits by branch name, for the
// branches updated from a known range. New branches have no range.
func CommitCounts(events []parser.Event, runner CommandRunner) map[string]int {
	counts := map[string]int{}
	for _, event := range events {
		if event.Type != parser.BranchUpdate || event.FromRef == "" {
			continue
		}
		output, err := runner("git", "rev-list", "--count", event.FromRef+".."+event.ToRef)
		if err != nil {
			continue
		}
		count, err := strconv.Atoi(strings.TrimSpace(output))
		if err != nil {
			continue
		}
		counts[event.Branch] = count
	}
	return counts
}

// Run executes the command, sends its stderr messages and finally a DoneMsg
// holding the exit code.
// The stdout lines are kept as raw output, because they carry the failure
// reason of git-branch-pull (branch missing on the remote), and as output
// messages, because they carry the dependency update output.
func Run(ctx context.Context, command []string, send func(tea.Msg)) {
	stderrReader, stderrWriter := io.Pipe()
	stdoutReader, stdoutWriter := io.Pipe()
	cmd := exec.CommandContext(ctx, command[0], command[1:]...)
	cmd.Stderr = stderrWriter
	cmd.Stdout = stdoutWriter
	cmd.WaitDelay = backgroundGrace

	var streams sync.WaitGroup
	streams.Add(2)
	go func() {
		defer streams.Done()
		StreamStderr(stderrReader, send)
	}()
	go func() {
		defer streams.Done()
		stream.Read(stdoutReader, send, func(line string) tea.Msg { return tui.OutputMsg{Line: line} })
	}()

	exitCode := wait(cmd, send)
	_ = stderrWriter.Close() // PipeWriter.Close always returns nil
	_ = stdoutWriter.Close()
	streams.Wait()
	send(progress.DoneMsg{ExitCode: exitCode})
}

// wait starts the command, waits for it and returns its exit code.
func wait(cmd *exec.Cmd, send func(tea.Msg)) int {
	if err := cmd.Start(); err != nil {
		send(progress.ErrorMsg{Raw: fmt.Sprint(err)})
		return 1
	}
	err := cmd.Wait()
	if err == nil || errors.Is(err, exec.ErrWaitDelay) {
		return cmd.ProcessState.ExitCode()
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		return exitErr.ExitCode()
	}
	return 1
}

// EnsureBranchUpdate adds a BranchUpdate event for the current branch when
// the pull moved HEAD but the fetch did not report the branch, because an
// earlier fetch had already updated its remote ref.
func EnsureBranchUpdate(events []parser.Event, branch string, startCommit string, endCommit string) []parser.Event {
	if startCommit == endCommit {
		return events
	}
	for _, event := range events {
		if event.Type == parser.BranchUpdate && event.Branch == branch {
			return events
		}
	}
	return append(events, parser.Event{Type: parser.BranchUpdate, Branch: branch, FromRef: startCommit, ToRef: endCommit})
}

// DependencyOutput returns the stdout lines that come from the dependency
// update, by dropping the lines git-branch-pull prints itself.
func DependencyOutput(lines []string) []string {
	var kept []string
	for _, line := range lines {
		if line == "Fetching tags..." ||
			strings.HasSuffix(line, " branch updated") ||
			strings.HasPrefix(line, "Switched to latest branch ") {
			continue
		}
		kept = append(kept, line)
	}
	return kept
}
