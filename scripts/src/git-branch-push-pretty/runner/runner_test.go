package runner

import (
	"strings"
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git-branch-push-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git-branch-push-pretty/tui"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	tea "github.com/charmbracelet/bubbletea"
)

// --- Argument parsing ---

func TestParseArgsPassesThroughPositionalArgs(t *testing.T) {
	runner := mockRunner(map[string]string{})
	_, _, pushArgs, err := ParseArgs([]string{"main", "origin"}, runner)
	require.NoError(t, err)
	require.GreaterOrEqual(t, len(pushArgs), 2)
	assert.Equal(t, "main", pushArgs[0])
	assert.Equal(t, "origin", pushArgs[1])
}

func TestParseArgsAppendsProgressFlag(t *testing.T) {
	runner := mockRunner(map[string]string{})
	_, _, pushArgs, err := ParseArgs([]string{"main", "origin"}, runner)
	require.NoError(t, err)
	require.NotEmpty(t, pushArgs)
	assert.Equal(t, "--progress", pushArgs[len(pushArgs)-1])
}

func TestParseArgsResolvesBranchWhenMissing(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "feature\n",
		"git-remote-current": "origin\n",
	})
	branch, _, _, err := ParseArgs([]string{}, runner)
	require.NoError(t, err)
	assert.Equal(t, "feature", branch)
}

func TestParseArgsResolvesRemoteWhenMissing(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "main\n",
		"git-remote-current": "upstream\n",
	})
	_, remote, _, err := ParseArgs([]string{}, runner)
	require.NoError(t, err)
	assert.Equal(t, "upstream", remote)
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
	require.NoError(t, err)
	assert.Equal(t, "develop", branch)
	assert.NotContains(t, calls, "git-branch-current")
}

func TestParseArgsPassesThroughFlags(t *testing.T) {
	runner := mockRunner(map[string]string{
		"git-branch-current": "main\n",
		"git-remote-current": "origin\n",
	})
	_, _, pushArgs, err := ParseArgs([]string{"--force"}, runner)
	require.NoError(t, err)
	assert.Contains(t, pushArgs, "--force")
}

// --- Event to message conversion ---

func TestEventToMsgConvertsProgress(t *testing.T) {
	event := parser.Event{Type: parser.Progress, Phase: "Writing", Percentage: 50}
	msg := EventToMsg(event)
	pm, ok := msg.(tui.ProgressMsg)
	require.True(t, ok, "expected ProgressMsg, got %T", msg)
	assert.Equal(t, "Writing", pm.Phase)
	assert.Equal(t, 50, pm.Percentage)
}

func TestEventToMsgConvertsError(t *testing.T) {
	event := parser.Event{Type: parser.Error, Raw: "rejected"}
	msg := EventToMsg(event)
	em, ok := msg.(tui.ErrorMsg)
	require.True(t, ok, "expected ErrorMsg, got %T", msg)
	assert.Equal(t, "rejected", em.Raw)
}

func TestEventToMsgConvertsUpToDate(t *testing.T) {
	event := parser.Event{Type: parser.UpToDate}
	msg := EventToMsg(event)
	assert.IsType(t, tui.UpToDateMsg{}, msg)
}

func TestEventToMsgReturnsNilForNoise(t *testing.T) {
	event := parser.Event{Type: parser.Noise}
	msg := EventToMsg(event)
	assert.Nil(t, msg)
}

func TestEventToMsgConvertsRefUpdateWithRefs(t *testing.T) {
	event := parser.Event{Type: parser.RefUpdate, FromRef: "abc1234", ToRef: "def5678"}
	msg := EventToMsg(event)
	rm, ok := msg.(tui.RefUpdateMsg)
	require.True(t, ok, "expected RefUpdateMsg, got %T", msg)
	assert.Equal(t, "abc1234", rm.FromRef)
	assert.Equal(t, "def5678", rm.ToRef)
}

func TestEventToMsgConvertsRemoteMessage(t *testing.T) {
	event := parser.Event{Type: parser.RemoteMessage, Raw: "https://github.com/user/repo/pull/new/feature"}
	msg := EventToMsg(event)
	rm, ok := msg.(tui.RemoteMessageMsg)
	require.True(t, ok, "expected RemoteMessageMsg, got %T", msg)
	assert.Equal(t, "https://github.com/user/repo/pull/new/feature", rm.Text)
}

func TestEventToMsgSkipsRefUpdateDestination(t *testing.T) {
	event := parser.Event{Type: parser.RefUpdate, Remote: "git@github.com:user/repo.git"}
	msg := EventToMsg(event)
	assert.Nil(t, msg)
}

// --- Stderr streaming ---

func TestStreamStderrSendsProgressMessages(t *testing.T) {
	input := "Counting objects: 100% (5/5), done.\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	// RawLineMsg + ProgressMsg
	require.Len(t, messages, 2)
	raw, ok := messages[0].(tui.RawLineMsg)
	require.True(t, ok, "first should be RawLineMsg, got %T", messages[0])
	assert.False(t, raw.Overwrite)
	assert.IsType(t, tui.ProgressMsg{}, messages[1])
}

func TestStreamStderrSendsRawLineForNoise(t *testing.T) {
	input := "Delta compression using up to 18 threads\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	// RawLineMsg only (noise produces no typed message)
	require.Len(t, messages, 1)
	raw, ok := messages[0].(tui.RawLineMsg)
	require.True(t, ok, "expected RawLineMsg, got %T", messages[0])
	assert.Equal(t, "Delta compression using up to 18 threads", raw.Line)
}

func TestStreamStderrSplitsOnCarriageReturn(t *testing.T) {
	input := "Counting objects: 50% (5/10)\rCounting objects: 100% (10/10)\n"
	reader := strings.NewReader(input)
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(reader, send)
	// 2x (RawLineMsg + ProgressMsg) = 4 messages
	require.Len(t, messages, 4)
	// CR-terminated line should have Overwrite=true
	firstRaw := messages[0].(tui.RawLineMsg)
	assert.True(t, firstRaw.Overwrite)
	first := messages[1].(tui.ProgressMsg)
	assert.Equal(t, 50, first.Percentage)
	// LF-terminated line should have Overwrite=false
	lastRaw := messages[2].(tui.RawLineMsg)
	assert.False(t, lastRaw.Overwrite)
	last := messages[3].(tui.ProgressMsg)
	assert.Equal(t, 100, last.Percentage)
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
