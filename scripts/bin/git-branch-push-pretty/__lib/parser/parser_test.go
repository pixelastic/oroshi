package parser

import "testing"

// --- Progress parsing ---

func TestParsesCountingObjectsDone(t *testing.T) {
	e := ParseLine("Counting objects: 100% (109/109), done.")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Counting objects")
	assertInt(t, "percentage", e.Percentage, 100)
	assertInt(t, "current", e.Current, 109)
	assertInt(t, "total", e.Total, 109)
}

func TestParsesCompressingObjectsInProgress(t *testing.T) {
	e := ParseLine("Compressing objects:  81% (72/89)")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Compressing objects")
	assertInt(t, "percentage", e.Percentage, 81)
	assertInt(t, "current", e.Current, 72)
	assertInt(t, "total", e.Total, 89)
}

func TestParsesWritingObjectsWithSpeed(t *testing.T) {
	e := ParseLine("Writing objects: 100% (106/106), 18.40 KiB | 3.68 MiB/s, done.")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Writing objects")
	assertInt(t, "percentage", e.Percentage, 100)
	assertInt(t, "current", e.Current, 106)
	assertInt(t, "total", e.Total, 106)
}

// --- Ref update parsing ---

func TestParsesRemote(t *testing.T) {
	e := ParseLine("To github.com:user/repo.git")
	assertType(t, e, RefUpdate)
	assertStr(t, "remote", e.Remote, "github.com:user/repo.git")
}

func TestParsesRefUpdate(t *testing.T) {
	e := ParseLine("   825ed95..107ad51  main -> main")
	assertType(t, e, RefUpdate)
	assertStr(t, "from", e.FromRef, "825ed95")
	assertStr(t, "to", e.ToRef, "107ad51")
	assertStr(t, "branch", e.Branch, "main")
}

func TestParsesForcedUpdate(t *testing.T) {
	e := ParseLine(" + abc1234...def5678 main -> main (forced update)")
	assertType(t, e, RefUpdate)
	assertStr(t, "from", e.FromRef, "abc1234")
	assertStr(t, "to", e.ToRef, "def5678")
	assertStr(t, "branch", e.Branch, "main")
	if !e.Forced {
		t.Error("expected Forced to be true")
	}
}

// --- Remote message parsing ---

func TestIdentifiesRemoteMessage(t *testing.T) {
	e := ParseLine("remote: Create a pull request for 'feature' on GitHub by visiting:")
	assertType(t, e, RemoteMessage)
	assertStr(t, "raw", e.Raw, "Create a pull request for 'feature' on GitHub by visiting:")
}

func TestRemoteProgressIsNotRemoteMessage(t *testing.T) {
	e := ParseLine("remote: Resolving deltas: 100% (30/30), completed with 5 local objects.")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Resolving deltas")
}

// --- Error parsing ---

func TestIdentifiesRejectedAsError(t *testing.T) {
	e := ParseLine("! [rejected] main -> main (non-fast-forward)")
	assertType(t, e, Error)
	assertStr(t, "raw", e.Raw, "[rejected] main -> main (non-fast-forward)")
}

func TestIdentifiesFatalAsError(t *testing.T) {
	e := ParseLine("fatal: repository 'https://...' not found")
	assertType(t, e, Error)
	assertStr(t, "raw", e.Raw, "repository 'https://...' not found")
}

// --- Up to date ---

func TestIdentifiesEverythingUpToDate(t *testing.T) {
	e := ParseLine("Everything up-to-date")
	assertType(t, e, UpToDate)
}

// --- Noise ---

func TestIdentifiesDeltaCompressionAsNoise(t *testing.T) {
	e := ParseLine("Delta compression using up to 18 threads")
	assertType(t, e, Noise)
}

func TestIdentifiesTotalAsNoise(t *testing.T) {
	e := ParseLine("Total 106 (delta 30), reused 0 (delta 0)")
	assertType(t, e, Noise)
}

func TestIdentifiesTrackingAsNoise(t *testing.T) {
	e := ParseLine("branch 'main' set up to track 'origin/main'.")
	assertType(t, e, Noise)
}

// --- Carriage return handling ---

func TestHandlesLeadingCarriageReturn(t *testing.T) {
	e := ParseLine("\rCompressing objects:  81% (72/89)")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Compressing objects")
	assertInt(t, "percentage", e.Percentage, 81)
}

func TestHandlesEmbeddedCarriageReturn(t *testing.T) {
	e := ParseLine("Compressing objects:  50% (5/10)\rCompressing objects: 100% (10/10)")
	assertType(t, e, Progress)
	assertStr(t, "phase", e.Phase, "Compressing objects")
	assertInt(t, "percentage", e.Percentage, 100)
	assertInt(t, "current", e.Current, 10)
	assertInt(t, "total", e.Total, 10)
}

// --- Helpers ---

func assertType(t *testing.T, e Event, expected EventType) {
	t.Helper()
	names := map[EventType]string{
		Progress: "Progress", RefUpdate: "RefUpdate", RemoteMessage: "RemoteMessage",
		Error: "Error", UpToDate: "UpToDate", Noise: "Noise",
	}
	if e.Type != expected {
		t.Errorf("expected type %s, got %s", names[expected], names[e.Type])
	}
}

func assertStr(t *testing.T, field, got, expected string) {
	t.Helper()
	if got != expected {
		t.Errorf("expected %s %q, got %q", field, expected, got)
	}
}

func assertInt(t *testing.T, field string, got, expected int) {
	t.Helper()
	if got != expected {
		t.Errorf("expected %s %d, got %d", field, expected, got)
	}
}
