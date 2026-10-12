package gittest

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewRepoCreatesRepositoryInTemporaryDirectory(t *testing.T) {
	repo := NewRepo(t)

	assert.DirExists(t, filepath.Join(repo, ".git"))
	assert.True(t, strings.HasPrefix(repo, os.TempDir()))
}

func TestNewRepoIgnoresGitVariablesExportedByHooks(t *testing.T) {
	decoy := t.TempDir()
	t.Setenv("GIT_DIR", decoy)
	t.Setenv("GIT_INDEX_FILE", filepath.Join(decoy, "index"))
	t.Setenv("GIT_OBJECT_DIRECTORY", filepath.Join(decoy, "objects"))
	t.Setenv("GIT_WORK_TREE", decoy)

	repo := NewRepo(t)

	assert.DirExists(t, filepath.Join(repo, ".git"))
	entries, err := os.ReadDir(decoy)
	require.NoError(t, err)
	assert.Empty(t, entries, "the git directory pointed to by the environment must stay untouched")
}

func TestIsolateRestoresVariablesAfterTheTest(t *testing.T) {
	t.Setenv("GIT_INDEX_FILE", "/original/index")

	t.Run("inner", func(t *testing.T) {
		Isolate(t)
		_, isSet := os.LookupEnv("GIT_INDEX_FILE")
		assert.False(t, isSet)
	})

	assert.Equal(t, "/original/index", os.Getenv("GIT_INDEX_FILE"))
}
