package runner

import (
	"context"
	"strings"
	"testing"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/tui"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/progress"
	"github.com/pixelastic/oroshi/scripts/src/git/lib/stream"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Event to message conversion ---

func TestEventToMsgConvertsProgress(t *testing.T) {
	msg := EventToMsg(parser.Event{Type: parser.Progress, Phase: "Receiving objects", Percentage: 50})
	pm, ok := msg.(progress.PhaseMsg)
	require.True(t, ok, "expected PhaseMsg, got %T", msg)
	assert.Equal(t, "Receiving objects", pm.Phase)
	assert.Equal(t, 50, pm.Percentage)
}

func TestEventToMsgConvertsError(t *testing.T) {
	msg := EventToMsg(parser.Event{Type: parser.Error, Raw: "boom"})
	em, ok := msg.(progress.ErrorMsg)
	require.True(t, ok, "expected ErrorMsg, got %T", msg)
	assert.Equal(t, "boom", em.Raw)
}

func TestEventToMsgKeepsBranchUpdatesAndTagsForTheRecap(t *testing.T) {
	for _, event := range []parser.Event{
		{Type: parser.BranchUpdate, Branch: "main"},
		{Type: parser.NewTag, Tag: "v1"},
	} {
		msg := EventToMsg(event)
		em, ok := msg.(tui.EventMsg)
		require.True(t, ok, "expected EventMsg, got %T", msg)
		assert.Equal(t, event, em.Event)
	}
}

func TestEventToMsgReturnsNilForNoise(t *testing.T) {
	assert.Nil(t, EventToMsg(parser.Event{Type: parser.Noise}))
}

// --- Stderr streaming ---

func TestStreamStderrSendsRawLineThenEvent(t *testing.T) {
	var messages []tea.Msg
	send := func(msg tea.Msg) { messages = append(messages, msg) }
	StreamStderr(strings.NewReader(" * [new tag]         v1         -> v1\n"), send)
	require.Len(t, messages, 2)
	assert.IsType(t, stream.LineMsg{}, messages[0])
	assert.IsType(t, tui.EventMsg{}, messages[1])
}

// --- Commit counts ---

func TestCommitCountsCountsCommitsInEachUpdatedRange(t *testing.T) {
	var calls [][]string
	runner := func(name string, args ...string) (string, error) {
		calls = append(calls, args)
		return "3\n", nil
	}
	events := []parser.Event{
		{Type: parser.BranchUpdate, Branch: "main", FromRef: "7202af2", ToRef: "9cd360a"},
		{Type: parser.BranchUpdate, Branch: "develop", New: true},
		{Type: parser.NewTag, Tag: "v1"},
	}
	counts := CommitCounts(events, runner)
	assert.Equal(t, map[string]int{"main": 3}, counts)
	require.Len(t, calls, 1)
	assert.Equal(t, []string{"rev-list", "--count", "7202af2..9cd360a"}, calls[0])
}

// --- Process run ---

func runCollecting(t *testing.T, script string) tui.Model {
	t.Helper()
	model := tui.New(42)
	send := func(msg tea.Msg) {
		updated, _ := model.Update(msg)
		model = updated.(tui.Model)
	}
	Run(context.Background(), []string{"sh", "-c", script}, send)
	return model
}

func TestRunKeepsRawStderrAndExitCodeWhenTheCommandFails(t *testing.T) {
	model := runCollecting(t, `echo "fatal: boom" >&2; echo "hint: try again" >&2; exit 3`)
	assert.Equal(t, 3, model.ExitCode())
	assert.Equal(t, "fatal: boom\nhint: try again", model.RawOutput())
}

func TestRunReturnsWithoutWaitingForBackgroundProcessesHoldingStderr(t *testing.T) {
	start := time.Now()
	model := runCollecting(t, `sleep 5 & echo "done" >&2`)
	assert.Equal(t, 0, model.ExitCode())
	assert.Equal(t, "done", model.RawOutput())
	assert.Less(t, time.Since(start), 3*time.Second)
}

// --- Current branch update ---

func TestEnsureBranchUpdateAddsTheCurrentBranchWhenHeadMovedWithoutAnEvent(t *testing.T) {
	events := []parser.Event{{Type: parser.BranchUpdate, Branch: "develop"}}
	result := EnsureBranchUpdate(events, "main", "aaa111", "bbb222")
	require.Len(t, result, 2)
	assert.Equal(t, parser.Event{Type: parser.BranchUpdate, Branch: "main", FromRef: "aaa111", ToRef: "bbb222"}, result[1])
}

func TestEnsureBranchUpdateKeepsEventsWhenTheCurrentBranchAlreadyHasOne(t *testing.T) {
	events := []parser.Event{{Type: parser.BranchUpdate, Branch: "main", FromRef: "aaa111", ToRef: "bbb222"}}
	assert.Equal(t, events, EnsureBranchUpdate(events, "main", "aaa111", "bbb222"))
}

func TestEnsureBranchUpdateKeepsEventsWhenHeadDidNotMove(t *testing.T) {
	assert.Empty(t, EnsureBranchUpdate(nil, "main", "aaa111", "aaa111"))
}

func TestRunKeepsRawStdoutWhenTheCommandFails(t *testing.T) {
	model := runCollecting(t, `echo "✘ Branch missing doesn't exist on origin"; exit 1`)
	assert.Equal(t, 1, model.ExitCode())
	assert.Equal(t, "✘ Branch missing doesn't exist on origin", model.RawOutput())
}

// --- Dependency output ---

func TestDependencyOutputDropsThePullOwnLines(t *testing.T) {
	lines := []string{"Fetching tags...", "Installing node modules", "main branch updated"}
	assert.Equal(t, []string{"Installing node modules"}, DependencyOutput(lines))
}

func TestDependencyOutputIsEmptyWhenNothingWasUpdated(t *testing.T) {
	lines := []string{"Fetching tags...", "Switched to latest branch develop"}
	assert.Empty(t, DependencyOutput(lines))
}
