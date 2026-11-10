package recap

import (
	"strings"
	"testing"

	"github.com/pixelastic/oroshi/scripts/src/git/git-branch-pull-pretty/parser"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type plainStyler struct{}

func (plainStyler) Branch(name string) string { return "[" + name + "]" }
func (plainStyler) Tag(name string) string    { return "<" + name + ">" }

func updated(branch string) parser.Event {
	return parser.Event{Type: parser.BranchUpdate, Branch: branch, FromRef: "7202af2", ToRef: "9cd360a"}
}

func TestPrintsAlreadyUpToDateWhenNothingChanged(t *testing.T) {
	events := []parser.Event{
		{Type: parser.Progress, Phase: "Receiving objects", Percentage: 100},
		{Type: parser.Noise},
	}
	lines := Lines(Input{Events: events}, plainStyler{})
	assert.Equal(t, []string{"Already up to date"}, lines)
}

func TestPrintsOneLineByUpdatedBranchWithCommitCount(t *testing.T) {
	input := Input{
		Events:  []parser.Event{updated("main"), updated("develop")},
		Commits: map[string]int{"main": 3, "develop": 1},
	}
	lines := Lines(input, plainStyler{})
	require.Len(t, lines, 2)
	assert.Equal(t, "[main] +3 commits", lines[0])
	assert.Equal(t, "[develop] +1 commit", lines[1])
}

func TestPrintsNoCommitHashes(t *testing.T) {
	input := Input{Events: []parser.Event{updated("main")}, Commits: map[string]int{"main": 3}}
	output := strings.Join(Lines(input, plainStyler{}), "\n")
	assert.NotContains(t, output, "7202af2")
	assert.NotContains(t, output, "9cd360a")
}

func TestFlagsNewBranches(t *testing.T) {
	events := []parser.Event{{Type: parser.BranchUpdate, Branch: "develop", New: true}}
	lines := Lines(Input{Events: events}, plainStyler{})
	assert.Equal(t, []string{"[develop] new"}, lines)
}

func TestFlagsForcedUpdates(t *testing.T) {
	event := updated("develop")
	event.Forced = true
	input := Input{Events: []parser.Event{event}, Commits: map[string]int{"develop": 2}}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] +2 commits forced"}, lines)
}

func TestListsEveryNewTag(t *testing.T) {
	events := []parser.Event{
		{Type: parser.NewTag, Tag: "v1"},
		{Type: parser.NewTag, Tag: "v2"},
		{Type: parser.NewTag, Tag: "v3"},
	}
	lines := Lines(Input{Events: events}, plainStyler{})
	require.Len(t, lines, 1)
	assert.Equal(t, "Tags: <v1> <v2> <v3>", lines[0])
}

func TestIncludesDiffstatBelowTheCurrentBranchLine(t *testing.T) {
	input := Input{
		Events:        []parser.Event{updated("main"), updated("develop")},
		Commits:       map[string]int{"main": 3, "develop": 1},
		CurrentBranch: "main",
		Diffstat:      "b | 1 +\n1 file changed",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{
		"[main] +3 commits",
		"b | 1 +",
		"1 file changed",
		"[develop] +1 commit",
	}, lines)
}

func TestOmitsDiffstatWhenAnotherBranchChanged(t *testing.T) {
	input := Input{
		Events:        []parser.Event{updated("develop")},
		Commits:       map[string]int{"develop": 1},
		CurrentBranch: "main",
		Diffstat:      "b | 1 +",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] +1 commit"}, lines)
}

func TestPrintsSwitchLineAfterTheRecapLine(t *testing.T) {
	input := Input{
		Events:        []parser.Event{updated("develop")},
		Commits:       map[string]int{"develop": 2},
		CurrentBranch: "main",
		SwitchedTo:    "develop",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] +2 commits", "Switched to [develop]"}, lines)
}

func TestPrintsSwitchLineAfterTags(t *testing.T) {
	input := Input{
		Events:     []parser.Event{updated("develop"), {Type: parser.NewTag, Tag: "v1"}},
		Commits:    map[string]int{"develop": 1},
		SwitchedTo: "develop",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] +1 commit", "Tags: <v1>", "Switched to [develop]"}, lines)
}

func TestFlagsTheSwitchedBranchAsNewWhenItDidNotExistLocally(t *testing.T) {
	input := Input{
		Events:     []parser.Event{{Type: parser.BranchUpdate, Branch: "develop", New: true}},
		SwitchedTo: "develop",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] new", "Switched to [develop]"}, lines)
}

func TestPrintsSwitchLineWhenTheSwitchedBranchWasAlreadyUpToDate(t *testing.T) {
	lines := Lines(Input{SwitchedTo: "develop"}, plainStyler{})
	assert.Equal(t, []string{"Already up to date", "Switched to [develop]"}, lines)
}

func TestOmitsDiffstatWhenSwitching(t *testing.T) {
	input := Input{
		Events:        []parser.Event{updated("develop")},
		Commits:       map[string]int{"develop": 1},
		CurrentBranch: "develop",
		Diffstat:      "b | 1 +",
		SwitchedTo:    "develop",
	}
	lines := Lines(input, plainStyler{})
	assert.Equal(t, []string{"[develop] +1 commit", "Switched to [develop]"}, lines)
}
