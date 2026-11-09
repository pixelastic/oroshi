package parser

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

// --- Progress parsing ---

func TestParsesCountingObjectsDone(t *testing.T) {
	e := ParseLine("Counting objects: 100% (109/109), done.")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Counting objects", e.Phase)
	assert.Equal(t, 100, e.Percentage)
	assert.Equal(t, 109, e.Current)
	assert.Equal(t, 109, e.Total)
}

func TestParsesCompressingObjectsInProgress(t *testing.T) {
	e := ParseLine("Compressing objects:  81% (72/89)")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Compressing objects", e.Phase)
	assert.Equal(t, 81, e.Percentage)
	assert.Equal(t, 72, e.Current)
	assert.Equal(t, 89, e.Total)
}

func TestParsesWritingObjectsWithSpeed(t *testing.T) {
	e := ParseLine("Writing objects: 100% (106/106), 18.40 KiB | 3.68 MiB/s, done.")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Writing objects", e.Phase)
	assert.Equal(t, 100, e.Percentage)
	assert.Equal(t, 106, e.Current)
	assert.Equal(t, 106, e.Total)
}

// --- Ref update parsing ---

func TestParsesRemote(t *testing.T) {
	e := ParseLine("To github.com:user/repo.git")
	assert.Equal(t, RefUpdate, e.Type)
	assert.Equal(t, "github.com:user/repo.git", e.Remote)
}

func TestParsesRefUpdate(t *testing.T) {
	e := ParseLine("   825ed95..107ad51  main -> main")
	assert.Equal(t, RefUpdate, e.Type)
	assert.Equal(t, "825ed95", e.FromRef)
	assert.Equal(t, "107ad51", e.ToRef)
	assert.Equal(t, "main", e.Branch)
}

func TestParsesForcedUpdate(t *testing.T) {
	e := ParseLine(" + abc1234...def5678 main -> main (forced update)")
	assert.Equal(t, RefUpdate, e.Type)
	assert.Equal(t, "abc1234", e.FromRef)
	assert.Equal(t, "def5678", e.ToRef)
	assert.Equal(t, "main", e.Branch)
	assert.True(t, e.Forced)
}

// --- Remote message parsing ---

func TestIdentifiesRemoteMessage(t *testing.T) {
	e := ParseLine("remote: Create a pull request for 'feature' on GitHub by visiting:")
	assert.Equal(t, RemoteMessage, e.Type)
	assert.Equal(t, "Create a pull request for 'feature' on GitHub by visiting:", e.Raw)
}

func TestRemoteProgressIsNotRemoteMessage(t *testing.T) {
	e := ParseLine("remote: Resolving deltas: 100% (30/30), completed with 5 local objects.")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Resolving deltas", e.Phase)
}

// --- Error parsing ---

func TestIdentifiesRejectedAsError(t *testing.T) {
	e := ParseLine("! [rejected] main -> main (non-fast-forward)")
	assert.Equal(t, Error, e.Type)
	assert.Equal(t, "[rejected] main -> main (non-fast-forward)", e.Raw)
}

func TestIdentifiesFatalAsError(t *testing.T) {
	e := ParseLine("fatal: repository 'https://...' not found")
	assert.Equal(t, Error, e.Type)
	assert.Equal(t, "repository 'https://...' not found", e.Raw)
}

// --- Up to date ---

func TestIdentifiesEverythingUpToDate(t *testing.T) {
	e := ParseLine("Everything up-to-date")
	assert.Equal(t, UpToDate, e.Type)
}

// --- Noise ---

func TestIdentifiesDeltaCompressionAsNoise(t *testing.T) {
	e := ParseLine("Delta compression using up to 18 threads")
	assert.Equal(t, Noise, e.Type)
}

func TestIdentifiesTotalAsNoise(t *testing.T) {
	e := ParseLine("Total 106 (delta 30), reused 0 (delta 0)")
	assert.Equal(t, Noise, e.Type)
}

func TestIdentifiesTrackingAsNoise(t *testing.T) {
	e := ParseLine("branch 'main' set up to track 'origin/main'.")
	assert.Equal(t, Noise, e.Type)
}

// --- Carriage return handling ---

func TestHandlesLeadingCarriageReturn(t *testing.T) {
	e := ParseLine("\rCompressing objects:  81% (72/89)")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Compressing objects", e.Phase)
	assert.Equal(t, 81, e.Percentage)
}

func TestHandlesEmbeddedCarriageReturn(t *testing.T) {
	e := ParseLine("Compressing objects:  50% (5/10)\rCompressing objects: 100% (10/10)")
	assert.Equal(t, Progress, e.Type)
	assert.Equal(t, "Compressing objects", e.Phase)
	assert.Equal(t, 100, e.Percentage)
	assert.Equal(t, 10, e.Current)
	assert.Equal(t, 10, e.Total)
}
