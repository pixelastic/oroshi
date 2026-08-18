package runner

import (
	"strings"
	"testing"

	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/parser"
	"github.com/pixelastic/oroshi/scripts/bin/git-branch-push-pretty/__lib/tui"

	tea "github.com/charmbracelet/bubbletea"
)

// --- Argument parsing ---

func TestParseArgsPassesThroughPositionalArgs(t *testing.T) {
	runner := mockRunner(map[string]string{})
	_, _, pushArgs, err := ParseArgs([]string{"main", "origin"}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(pushArgs) < 2 || pushArgs[0] != "main" || pushArgs[1] != "origin" {
		t.Errorf("pushArgs should start with main origin, got: %v", pushArgs)
	}
}

func TestParseArgsAppendsProgressFlag(t *testing.T) {
	runner := mockRunner(map[string]string{})
	_, _, pushArgs, err := ParseArgs([]string{"main", "origin"}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(pushArgs) == 0 {
		t.Fatal("pushArgs should not be empty")
	}
	last := pushArgs[len(pushArgs)-1]
	if last != "--progress" {
		t.Errorf("last arg should be --progress, got %q", last)
	}
}

func TestParseArgsResolvesBranchWhenMissing(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "feature\n",
		"git-remote-current": "origin\n",
	})
	branch, _, _, err := ParseArgs([]string{}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if branch != "feature" {
		t.Errorf("expected branch 'feature', got %q", branch)
	}
}

func TestParseArgsResolvesRemoteWhenMissing(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "main\n",
		"git-remote-current": "upstream\n",
	})
	_, remote, _, err := ParseArgs([]string{}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if remote != "upstream" {
		t.Errorf("expected remote 'upstream', got %q", remote)
	}
}

func TestParseArgsUsesProvidedBranchWithoutResolving(t *testing.T) {
	calls := []string{}
	runner := func(name string, args ...string) (string, error) {
		if len(args) > 0 {
			calls = append(calls, args[0])
		}
		if len(args) > 0 && args[0] == "git-remote-current" {
			return "origin\n", nil
		}
		return "", nil
	}
	branch, _, _, err := ParseArgs([]string{"develop"}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if branch != "develop" {
		t.Errorf("expected branch 'develop', got %q", branch)
	}
	for _, call := range calls {
		if call == "git-branch-current" {
			t.Error("should not resolve branch when provided")
		}
	}
}

func TestParseArgsPassesThroughFlags(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "main\n",
		"git-remote-current": "origin\n",
	})
	_, _, pushArgs, err := ParseArgs([]string{"--force"}, runner)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	foundForce := false
	for _, a := range pushArgs {
		if a == "--force" {
			foundForce = true
		}
	}
	if !foundForce {
		t.Error("pushArgs should contain --force")
	}
}

// --- Event to message conversion ---

func TestEventToMsgConvertsProgress(t *testing.T) {
	event := parser.Event{Type: parser.Progress, Phase: "Writing", Percentage: 50}
	msg := EventToMsg(event)
	pm, ok := msg.(tui.ProgressMsg)
	if !ok {
		t.Fatalf("expected ProgressMsg, got %T", msg)
	}
	if pm.Phase != "Writing" || pm.Percentage != 50 {
		t.Errorf("wrong ProgressMsg: %+v", pm)
	}
}

func TestEventToMsgConvertsError(t *testing.T) {
	event := parser.Event{Type: parser.Error, Raw: "rejected"}
	msg := EventToMsg(event)
	em, ok := msg.(tui.ErrorMsg)
	if !ok {
		t.Fatalf("expected ErrorMsg, got %T", msg)
	}
	if em.Raw != "rejected" {
		t.Errorf("expected 'rejected', got %q", em.Raw)
	}
}

func TestEventToMsgConvertsUpToDate(t *testing.T) {
	event := parser.Event{Type: parser.UpToDate}
	msg := EventToMsg(event)
	if _, ok := msg.(tui.UpToDateMsg); !ok {
		t.Fatalf("expected UpToDateMsg, got %T", msg)
	}
}

func TestEventToMsgReturnsNilForNoise(t *testing.T) {
	event := parser.Event{Type: parser.Noise}
	msg := EventToMsg(event)
	if msg != nil {
		t.Errorf("expected nil for Noise, got %T", msg)
	}
}

// --- Stderr streaming ---

func TestStreamStderrSendsProgressMessages(t *testing.T) {
	input := "Counting objects: 100% (5/5), done.\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	if len(messages) != 1 {
		t.Fatalf("expected 1 message, got %d", len(messages))
	}
	if _, ok := messages[0].(tui.ProgressMsg); !ok {
		t.Errorf("expected ProgressMsg, got %T", messages[0])
	}
}

func TestStreamStderrIgnoresNoiseLines(t *testing.T) {
	input := "Delta compression using up to 18 threads\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	if len(messages) != 0 {
		t.Errorf("expected 0 messages for noise, got %d", len(messages))
	}
}

func TestStreamStderrSplitsOnCarriageReturn(t *testing.T) {
	input := "Counting objects: 50% (5/10)\rCounting objects: 100% (10/10)\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	if len(messages) != 2 {
		t.Fatalf("expected 2 messages, got %d", len(messages))
	}
	first := messages[0].(tui.ProgressMsg)
	if first.Percentage != 50 {
		t.Errorf("first should be 50%%, got %d%%", first.Percentage)
	}
	last := messages[1].(tui.ProgressMsg)
	if last.Percentage != 100 {
		t.Errorf("last should be 100%%, got %d%%", last.Percentage)
	}
}

// --- helpers ---

func mockRunner(responses map[string]string) func(string, ...string) (string, error) {
	return func(name string, args ...string) (string, error) {
		if len(args) > 0 {
			if resp, ok := responses[args[0]]; ok {
				return resp, nil
			}
		}
		return "", nil
	}
}
