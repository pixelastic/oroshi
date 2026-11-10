package parser

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// Fixtures below are real `git fetch --tags --progress` stderr lines.

func TestParsesProgressLine(t *testing.T) {
	e := ParseLine("remote: Counting objects:  42% (3/7)        ")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Counting objects", e.Phase)
	assert.Equal(t, 42, e.Percentage)
}

func TestParsesProgressLineWithoutRemotePrefix(t *testing.T) {
	e := ParseLine("Receiving objects: 100% (7/7), 1.20 KiB | 1.20 MiB/s, done.")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Receiving objects", e.Phase)
	assert.Equal(t, 100, e.Percentage)
}

func TestParsesUpdatedBranchLine(t *testing.T) {
	e := ParseLine("   7202af2..9cd360a  main       -> origin/main")
	assert.Equal(t, BranchUpdate, e.Type)
	assert.Equal(t, "main", e.Branch)
	assert.Equal(t, "7202af2", e.FromRef)
	assert.Equal(t, "9cd360a", e.ToRef)
	assert.False(t, e.New)
	assert.False(t, e.Forced)
}

func TestParsesNewBranchLine(t *testing.T) {
	e := ParseLine(" * [new branch]      develop    -> origin/develop")
	assert.Equal(t, BranchUpdate, e.Type)
	assert.Equal(t, "develop", e.Branch)
	assert.True(t, e.New)
	assert.False(t, e.Forced)
}

func TestParsesForcedUpdateLine(t *testing.T) {
	e := ParseLine(" + c362235...6292b50 develop    -> origin/develop  (forced update)")
	assert.Equal(t, BranchUpdate, e.Type)
	assert.Equal(t, "develop", e.Branch)
	assert.Equal(t, "c362235", e.FromRef)
	assert.Equal(t, "6292b50", e.ToRef)
	assert.True(t, e.Forced)
	assert.False(t, e.New)
}

func TestParsesNewTagLine(t *testing.T) {
	e := ParseLine(" * [new tag]         v1         -> v1")
	assert.Equal(t, NewTag, e.Type)
	assert.Equal(t, "v1", e.Tag)
}

func TestParsesErrorLine(t *testing.T) {
	e := ParseLine("fatal: '/nonexistent' does not appear to be a git repository")
	assert.Equal(t, Error, e.Type)
	assert.Equal(t, "'/nonexistent' does not appear to be a git repository", e.Raw)
}

func TestClassifiesOtherLinesAsNoise(t *testing.T) {
	lines := []string{
		"remote: Enumerating objects: 7, done.        ",
		"remote: Total 6 (delta 1), reused 0 (delta 0), pack-reused 0        ",
		"From /tmp/remote",
		" * branch            main       -> FETCH_HEAD",
		"",
	}
	for _, line := range lines {
		assert.Equal(t, Noise, ParseLine(line).Type, line)
	}
}
