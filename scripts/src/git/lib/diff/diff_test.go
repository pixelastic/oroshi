package diff

import (
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// --- Numstat parsing ---

func TestParsesAdditionsAndDeletionsFromNumstat(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "10\t3\tsrc/main.go\n",
		"name-status": "M\tsrc/main.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, 10, changes[0].Additions)
	assert.Equal(t, 3, changes[0].Deletions)
}

func TestDetectsBinaryFilesFromNumstat(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "-\t-\timage.png\n",
		"name-status": "A\timage.png\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.True(t, changes[0].IsBinary)
	assert.Equal(t, 0, changes[0].Additions)
	assert.Equal(t, 0, changes[0].Deletions)
}

func TestHandlesEmptyDiffReturningEmptySlice(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "",
		"name-status": "",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	assert.Empty(t, changes)
}

// --- Name-status parsing ---

func TestParsesAddedStatusFromAPrefix(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "5\t0\tnew.go\n",
		"name-status": "A\tnew.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, Added, changes[0].Status)
}

func TestParsesModifiedStatusFromMPrefix(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "2\t1\texisting.go\n",
		"name-status": "M\texisting.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, Modified, changes[0].Status)
}

func TestParsesDeletedStatusFromDPrefix(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "0\t10\told.go\n",
		"name-status": "D\told.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, Deleted, changes[0].Status)
}

func TestParsesRenamedStatusFromRPrefixWithOldAndNewPaths(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "0\t0\told.go\tnew.go\n",
		"name-status": "R100\told.go\tnew.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, Renamed, changes[0].Status)
	assert.Equal(t, "new.go", changes[0].Path)
	assert.Equal(t, "old.go", changes[0].OldPath)
}

// --- Combined ---

func TestMergesNumstatAndNameStatusIntoUnifiedSlice(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "10\t2\tsrc/a.go\n5\t0\tsrc/b.go\n",
		"name-status": "M\tsrc/a.go\n" + "A\tsrc/b.go\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 2)
	assert.Equal(t, "src/a.go", changes[0].Path)
	assert.Equal(t, Modified, changes[0].Status)
	assert.Equal(t, 10, changes[0].Additions)
	assert.Equal(t, "src/b.go", changes[1].Path)
	assert.Equal(t, Added, changes[1].Status)
	assert.Equal(t, 5, changes[1].Additions)
}

func TestBinaryFileHasIsBinaryTrueAndZeroCounts(t *testing.T) {
	runner := mockRunner(map[string]string{
		"numstat":     "-\t-\tphoto.jpg\n",
		"name-status": "M\tphoto.jpg\n",
	})
	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.True(t, changes[0].IsBinary)
	assert.Equal(t, 0, changes[0].Additions)
	assert.Equal(t, 0, changes[0].Deletions)
}

// --- Submodule expansion ---

func TestExpandsSubmoduleIntoInnerFileChanges(t *testing.T) {
	callCount := 0
	runner := func(name string, args ...string) (string, error) {
		joined := strings.Join(args, " ")

		if strings.Contains(joined, "diff-tree") {
			// First call: superproject diff-tree shows submodule
			return ":160000 160000 aaa bbb M\tprivate\n", nil
		}

		// Track whether this is superproject or submodule query
		isSubmodule := strings.Contains(joined, "-C /repo/private")

		if strings.Contains(joined, "--numstat") {
			if isSubmodule {
				return "5\t2\tconfig/app.yml\n", nil
			}
			callCount++
			return "1\t1\tprivate\n", nil
		}
		if strings.Contains(joined, "--name-status") {
			if isSubmodule {
				return "M\tconfig/app.yml\n", nil
			}
			return "M\tprivate\n", nil
		}
		return "", fmt.Errorf("unexpected: %s", joined)
	}

	changes, err := Query("abc", "def", "/repo", runner)
	require.NoError(t, err)
	require.Len(t, changes, 1)
	assert.Equal(t, "private/config/app.yml", changes[0].Path)
	assert.Equal(t, Modified, changes[0].Status)
	assert.Equal(t, 5, changes[0].Additions)
	assert.Equal(t, 2, changes[0].Deletions)
}

// --- helpers ---

// mockRunner returns a CommandRunner that responds based on whether the args
// contain "--numstat", "--name-status", or "diff-tree".
func mockRunner(responses map[string]string) CommandRunner {
	return func(name string, args ...string) (string, error) {
		joined := strings.Join(args, " ")
		if strings.Contains(joined, "diff-tree") {
			return responses["diff-tree"], nil
		}
		if strings.Contains(joined, "--numstat") {
			return responses["numstat"], nil
		}
		if strings.Contains(joined, "--name-status") {
			return responses["name-status"], nil
		}
		return "", fmt.Errorf("unexpected command: %s %s", name, joined)
	}
}
